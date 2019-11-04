//
//  AuthenticationController.swift
//  VimeoNetworkingExample-iOS
//
//  Created by Huebner, Rob on 3/21/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
 `AuthenticationController` is used to authenticate a `VimeoClient` instance, either by loading an account stored in the system keychain, or by interacting with the Vimeo API to authenticate a new account.  The two publicly accessible authentication methods are client credentials grant and code grant.
 
 Client credentials grant is a public authentication method with no logged in user, which allows your application to access anything a logged out user could see on Vimeo (public content).
 
 Code grant is a way of logging in with a user account, which can give your application access to that user's private content and permission to interact with Vimeo on their behalf.  This is achieved by first opening a generated URL in Safari which presents a user log in page.  When the user authenticates successfully, control is returned to your app through a redirect link, and you then make a final request to retrieve the authenticated account.
 
 - Note: This class contains implementation details of private Vimeo-internal authentication methods in addition to the public authentication methods mentioned above.  However, only client credentials grant and code grant authentication are supported for 3rd-party applications interacting with Vimeo.  None of the other authentication endpoints are enabled for non-official applications, nor will they ever be, so please don't attempt to use them.  Perhaps you're thinking, "Why are they here at all, then?"  Well, Vimeo's official applications use this very same library to interact with the Vimeo API, and this, more than anything, is what keeps `VimeoNetworking` healthy and well-maintained :).
 */
final public class AuthenticationController {
    
    private struct Constants {
        /// The domain for errors generated by `AuthenticationController`
        static let ErrorDomain = "AuthenticationControllerErrorDomain"
        static let ResponseTypeKey = "response_type"
        static let CodeKey = "code"
        static let ClientIDKey = "client_id"
        static let RedirectURIKey = "redirect_uri"
        static let ScopeKey = "scope"
        static let StateKey = "state"
        static let CodeGrantAuthorizationPath = "oauth/authorize"
    }
    
    
    private static let PinCodeRequestInterval: TimeInterval = 5
    
        /// Completion closure type for authentication requests
    public typealias AuthenticationCompletion = ResultCompletion<VIMAccount>.T
    
        /// State is tracked for the code grant request/response cycle, to avoid interception
    static let state = ProcessInfo.processInfo.globallyUniqueString
    
        /// Application configuration used to retrieve authentication parameters
    private let configuration: AppConfiguration
    
        /// External client, authenticated on a successful request
    private let client: VimeoClient
    
        /// We need to use a separate client to make the actual auth requests, to ensure it's unauthenticated
    private let authenticatorClient: VimeoClient
    
        /// Persists authenticated accounts to disk
    private let accountStore: AccountStore
    
        /// Set to false to stop the refresh cycle for pin code auth
    private var continuePinCodeAuthorizationRefreshCycle = true
    
    /// Create a new `AuthenticationController`
    ///
    /// - Parameters:
    ///   - client: a client to authenticate
    ///   - appConfiguration: a configuration
    ///   - configureSessionManagerBlock: a block to configure the session manager
    public init(client: VimeoClient, appConfiguration: AppConfiguration, configureSessionManagerBlock: ConfigureSessionManagerBlock?) {
        self.configuration = appConfiguration
        self.client = client
        self.accountStore = AccountStore(configuration: appConfiguration)
        
        self.authenticatorClient = VimeoClient(appConfiguration: appConfiguration, configureSessionManagerBlock: configureSessionManagerBlock)
    }
    
    // MARK: - Public Saved Accounts
    
    public func loadClientCredentialsAccount() throws -> VIMAccount? {
        return try self.loadAccount(accountType: .clientCredentials)
    }

    public func loadUserAccount() throws -> VIMAccount? {
        return try self.loadAccount(accountType: .user)
    }
    
    @available(*, deprecated, message: "Use loadUserAccount or loadClientCredentialsAccount instead.")
    /**
     Load a saved User or Client credentials account from the `AccountStore`
     
     - throws: an error if storage returns a failure
     
     - returns: an account, if found
     */
    public func loadSavedAccount() throws -> VIMAccount? {
        var loadedAccount = try self.loadUserAccount()
        
        if loadedAccount == nil {
            loadedAccount = try self.loadClientCredentialsAccount()
        }
        
        if let _ = loadedAccount {
            // TODO: refresh user [RH] (4/25/16)
            
            // TODO: after refreshing user, send notification [RH] (4/25/16)
        }
        
        return loadedAccount
    }
    
    public func saveAccount(account: VIMAccount) throws {
        let accountType: AccountStore.AccountType = (account.user != nil) ? .user : .clientCredentials
        
        try self.accountStore.save(account, ofType: accountType)
    }
    
    // MARK: - Private Saved Accounts
    
    private func loadAccount(accountType: AccountStore.AccountType) throws -> VIMAccount? {
        let loadedAccount = try self.accountStore.loadAccount(ofType: accountType)
        
        if let loadedAccount = loadedAccount {
            print("Loaded \(accountType) account \(loadedAccount)")

            try self.setClientAccount(with: loadedAccount)
        }
        else {
            // TODO: We should probably surface this error to the client
            print("Failed to load \(accountType) account")
        }
        return loadedAccount
    }

    // MARK: - Public Authentication
    
    /**
     Execute a client credentials grant request.  This type of authentication allows access to public content on Vimeo.
     
     - parameter completion: handles authentication success or failure
     */
    public func clientCredentialsGrant(completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.clientCredentialsGrantRequest(scopes: self.configuration.scopes)
        
        self.authenticate(with: request, completion: completion)
    }
    
        /// Returns the redirect URI used to launch this application after code grant authorization
    public var codeGrantRedirectURI: String {
        let scheme = "vimeo\(self.configuration.clientIdentifier)"
        let path = "auth"
        let URI = "\(scheme)://\(path)"
        
        return URI
    }
    
    /**
     Generate a URL to open the Vimeo code grant authorization page.  When opened in Safari, this page allows users to log into your application.
     
     - returns: the code grant authorization page URL
     */
    public func codeGrantAuthorizationURL() -> URL {
        let parameters = [Constants.ResponseTypeKey: Constants.CodeKey,
                          Constants.ClientIDKey: self.configuration.clientIdentifier,
                          Constants.RedirectURIKey: self.codeGrantRedirectURI,
                          Constants.ScopeKey: Scope.combine(self.configuration.scopes),
                          Constants.StateKey: type(of: self).state]
        
        let urlString = self.configuration.baseUrl.appendingPathComponent(Constants.CodeGrantAuthorizationPath).absoluteString
        
        var error: NSError?
        let urlRequest = VimeoRequestSerializer(appConfiguration: self.configuration).request(withMethod: VimeoClient.Method.GET.rawValue, urlString: urlString, parameters: parameters, error: &error)
        
        guard let url = urlRequest.url, error == nil
        else {
            fatalError("Could not make code grant auth URL")
        }
        
        return url
    }
    
    /**
     Finish code grant authentication.  This function initiates the final step of the code grant process.  After your application is relaunched with the redirect URL, make this request with the response URL to retrieve the authenticated account.
     
     - parameter responseURL: the URL that was used to relaunch your application
     - parameter completion:  handler for authentication success or failure
     */
    public func codeGrant(responseURL: URL, completion: @escaping AuthenticationCompletion) {
        guard let queryString = responseURL.query,
            let parametersDictionary = queryString.parametersDictionaryFromQueryString(),
            let code = parametersDictionary[Constants.CodeKey],
            let state = parametersDictionary[Constants.StateKey]
        else {
            let errorDescription = "Could not retrieve parameters from code grant response"
            
            assertionFailure(errorDescription)
            
            let error = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.codeGrant.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
            
            completion(.failure(error: error))
            
            return
        }
        
        if state != type(of: self).state {
            let errorDescription = "Code grant returned state did not match existing state"
            
            assertionFailure(errorDescription)
            
            let error = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.codeGrantState.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
            
            completion(.failure(error: error))
            
            return
        }
        
        let request = AuthenticationRequest.codeGrantRequest(withCode: code, redirectURI: self.codeGrantRedirectURI)
        
        self.authenticate(with: request, completion: completion)
    }
    
    /**
     Execute a constant token grant request. This type of authentication allows access to public and personnal content on Vimeo. Constant token are usually generated for API apps see https://developer.vimeo.com/apps
     
     - parameter token: a constant token generated for your api's app
     - parameter completion: handles authentication success or failure
     */
    public func accessToken(token: String, completion: @escaping AuthenticationCompletion) {
        let customSessionManager =  VimeoSessionManager.defaultSessionManager(baseUrl: self.configuration.baseUrl, accessTokenProvider: {token}, apiVersion: self.configuration.apiVersion)
        let adhocClient = VimeoClient(appConfiguration: self.configuration, sessionManager: customSessionManager)
        let request = AuthenticationRequest.verifyAccessTokenRequest()

        self.authenticate(with: adhocClient, request: request, completion: completion)
    }
    
    // MARK: - Private Authentication
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Log in with an email and password
     
     - parameter email:      a user's email
     - parameter password:   a user's password
     - parameter completion: handler for authentication success or failure
     */
    public func logIn(withEmail email: String, password: String, completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.logInRequest(withEmail: email, password: password, scopes: self.configuration.scopes)
        
        self.authenticate(with: request, completion: completion)
    }
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Join with a username, email, and password
     
     - parameter name:       the new user's name
     - parameter email:      the new user's email
     - parameter password:   the new user's password
     - parameter completion: handler for authentication success or failure
     */
    public func join(withName name: String, email: String, password: String, marketingOptIn: String, completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.joinRequest(withName: name, email: email, password: password, marketingOptIn: marketingOptIn, scopes: self.configuration.scopes)
        
        self.authenticate(with: request, completion: completion)
    }
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Log in with a facebook token
     
     - parameter facebookToken: token from facebook SDK
     - parameter completion:    handler for authentication success or failure
     */
    public func facebookLogIn(withToken facebookToken: String, completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.logInFacebookRequest(withToken: facebookToken, scopes: self.configuration.scopes)
        
        self.authenticate(with: request, completion: completion)
    }
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Join with a facebook token
     
     - parameter facebookToken: token from facebook SDK
     - parameter completion:    handler for authentication success or failure
     */
    public func facebookJoin(withToken facebookToken: String, marketingOptIn: String, completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.joinFacebookRequest(withToken: facebookToken, marketingOptIn: marketingOptIn, scopes: self.configuration.scopes)
        
        self.authenticate(with: request, completion: completion)
    }
    
    /**
     **(PRIVATE: Vimeo Use Only)**
     Log in with an account response dictionary
     
     - parameter accountResponseDictionary: account response dictionary
     - parameter completion:                handler for authentication success or failure
     */
    public func authenticate(withResponse accountResponseDictionary: VimeoClient.ResponseDictionary, completion: AuthenticationCompletion) {
        let result: Result<Response<VIMAccount>>
        
        do {
            let account: VIMAccount = try VIMObjectMapper.mapObject(responseDictionary: accountResponseDictionary)
            
            let response = Response(model: account, json: accountResponseDictionary)
            
            result = Result.success(result: response)
        }
        catch let error as NSError {
            result = Result.failure(error: error)
        }
        
        let handledResult = self.handleAuthenticationResult(result)
        
        completion(handledResult)
    }
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Exchange a saved access token granted to another application for a new token granted to the calling application.  This method will allow an application to re-use credentials from another Vimeo application.  Client credentials must be granted before using this method.
     
     - parameter accessToken: access token granted to the other application
     - parameter completion:  handler for authentication success or failure
     */
    public func appTokenExchange(accessToken: String, completion: @escaping AuthenticationCompletion) {
        let request = AuthenticationRequest.appTokenExchangeRequest(withAccessToken: accessToken)
        
        self.authenticate(with: request, completion: completion)
    }
    
    
        /// **(PRIVATE: Vimeo Use Only)** Handles the initial information to present to the user for pin code auth
    public typealias PinCodeInfoHander = (String, String) -> Void
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Pin code authentication, for connected but keyboardless devices like Apple TV.  This is a long and highly asynchronous process where the user is initially presented a pin code, which they then enter into a special page on Vimeo.com on a different device.  Back on the original device, the app is polling the api to check whether the pin code has been authenticated.  The `infoHandler` will be called after an initial request to retrieve the pin code and activate link.  `AuthenticationController` will handle polling the api to check if the code has been activated, and it will ultimately call the completion handler when that happens.  If the pin code expires while we're waiting, completion will be called with an error
     
     - parameter infoHandler: handler for initial information presentation
     - parameter completion:  handler for authentication success or failure
     */
    public func pinCode(infoHandler: @escaping PinCodeInfoHander, completion: @escaping AuthenticationCompletion) {
        let infoRequest = PinCodeRequest.getPinCodeRequest(forScopes: self.configuration.scopes)
        
        let _ = self.authenticatorClient.request(infoRequest) { result in
            switch result {
            case .success(let result):
                
                let info = result.model
                
                guard let userCode = info.userCode,
                    let deviceCode = info.deviceCode,
                    let activateLink = info.activateLink, info.expiresIn > 0
                else {
                    let errorDescription = "Malformed pin code info returned"
                    
                    assertionFailure(errorDescription)
                    
                    let error = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.pinCodeInfo.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    
                    completion(.failure(error: error))
                    
                    return
                }
                
                infoHandler(userCode, activateLink)
                
                let expirationDate = Date(timeIntervalSinceNow: TimeInterval(info.expiresIn))
                
                self.continuePinCodeAuthorizationRefreshCycle = true
                self.doPinCodeAuthorization(userCode: userCode, deviceCode: deviceCode, expirationDate: expirationDate, completion: completion)
                
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    private func doPinCodeAuthorization(userCode: String, deviceCode: String, expirationDate: Date, completion: @escaping AuthenticationCompletion) {
        guard Date().compare(expirationDate) == .orderedAscending
        else {
            let description = "Pin code expired"
            
            let error = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.pinCodeExpired.rawValue, userInfo: [NSLocalizedDescriptionKey: description])
            
            completion(.failure(error: error))
            
            return
        }
        
        let authorizationRequest = AuthenticationRequest.authorizePinCodeRequest(withUserCode: userCode, deviceCode: deviceCode)
        
        self.authenticate(with: authorizationRequest) { [weak self] result in
            
            switch result {
            case .success:
                completion(result)
                
            case .failure(let error):
                if error.statusCode == HTTPStatusCode.badRequest.rawValue // 400: Bad Request implies the code hasn't been activated yet, so try again.
                {
                    guard let strongSelf = self
                        else {
                        return
                    }
                    
                    if strongSelf.continuePinCodeAuthorizationRefreshCycle {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(type(of: strongSelf).PinCodeRequestInterval * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
                            
                            self?.doPinCodeAuthorization(userCode: userCode, deviceCode: deviceCode, expirationDate: expirationDate, completion: completion)
                        }
                    }
                }
                else // Any other error is an actual error, and should get reported back.
                {
                    completion(result)
                }
            }
        }
    }
    
    /**
     **(PRIVATE: Vimeo Use Only, will not work for third-party applications)**
     Cancels an ongoing pin code authentication process
     */
    public func cancelPinCode() {
        self.continuePinCodeAuthorizationRefreshCycle = false
    }
    
    // MARK: - Log out
    
    /**
     Log out the account of the client

     - parameter loadClientCredentials: if true, tries to load a client credentials account from the keychain after logging out
     
     - throws: an error if the account could not be deleted from the keychain
     */
    public func logOut(loadClientCredentials: Bool = true) throws {
        guard self.client.currentAccount?.isAuthenticatedWithUser() == true
        else {
            return
        }
        
        let deleteTokensRequest = Request<VIMNullResponse>.deleteTokensRequest()
        let _ = self.client.request(deleteTokensRequest) { (result) in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("could not delete tokens: \(error)")
            }
        }
        
        if loadClientCredentials {
            let loadedClientCredentialsAccount = (((try? self.accountStore.loadAccount(ofType: .clientCredentials)) as VIMAccount??)) ?? nil
            try self.setClientAccount(with: loadedClientCredentialsAccount, shouldClearCache: true)
        }
        else {
            try self.setClientAccount(with: nil, shouldClearCache: true)
        }
        
        try self.accountStore.removeAccount(ofType: .user)
    }
    
    /**
     Executes the specified authentication request, then the specified completion.
     
        - request: A request to fetch a VIMAccount.
        - completion: A closure to handle the VIMAccount or error received.
     */
    public func authenticate(with request: AuthenticationRequest, completion: @escaping AuthenticationCompletion) {
        self.authenticate(with: self.authenticatorClient, request: request, completion: completion)
    }
    
    // MARK: - Private
    
    private func authenticate(with client: VimeoClient, request: AuthenticationRequest, completion: @escaping AuthenticationCompletion) {
        let _ = client.request(request) { result in
            
            let handledResult = self.handleAuthenticationResult(result)
            
            completion(handledResult)
        }
    }
    
    private func handleAuthenticationResult(_ result: Result<Response<VIMAccount>>) -> Result<VIMAccount> {
        guard case .success(let accountResponse) = result
        else {
            let resultError: NSError
            if case .failure(let error) = result {
                resultError = error
            }
            else {
                let errorDescription = "Authentication result malformed"
                
                assertionFailure(errorDescription)
                
                resultError = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.noResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
            }
            
            return .failure(error: resultError)
        }
        
        let account = accountResponse.model
        
        if let userJSON = accountResponse.json["user"] as? VimeoClient.ResponseDictionary {
            account.userJSON = userJSON
        }
        
        do {
            try self.setClientAccount(with: account, shouldClearCache: true)
            
            let accountType: AccountStore.AccountType = (account.user != nil) ? .user : .clientCredentials
            
            try self.accountStore.save(account, ofType: accountType)
        }
        catch let error {
            return .failure(error: error as NSError)
        }
        
        return .success(result: account)
    }
    
    private func setClientAccount(with account: VIMAccount?, shouldClearCache: Bool = false) throws {
        // Account can be nil (to log out) but if it's non-nil, it needs an access token or it's malformed [RH]
        guard account == nil || account?.accessToken != nil
        else {
            let errorDescription = "AuthenticationController tried to set a client account with no access token"
            
            assertionFailure(errorDescription)
            
            let error = NSError(domain: Constants.ErrorDomain, code: LocalErrorCode.authToken.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
            
            throw error
        }
        
        if shouldClearCache {
            self.client.removeAllCachedResponses()
        }
        
        self.client.currentAccount = account
    }
}
