//
//  VimeoService.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 18/09/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import Foundation
import VimeoNetworking
import AVKit

final class VimeoService {
    
    // MARK: Static properties
    static var current = VimeoService()
    
    // MARK: - Properties
    private var appConfiguration: AppConfiguration {
        return AppConfiguration(
            clientIdentifier: "9b46081fd51719f8427c41d819379fdfdad274bb", clientSecret: "C+oL8GB7Qk5f2NDECSlX08EOI1lINMgdEtmT91h5kMYakJW2vvPHbWKdWkFDin1X3n4T+IlolJiK6qFQ9rzZUleCSn6njbNpCZP1LxACieRFARL1KZaDeSIOPeYv7KH5",
            scopes: [.Public, .Private, .VideoFiles], keychainService: "KeychainServiceVimeo")
    }
    
    private var sessionManager = VimeoSessionManager.defaultSessionManager(
        baseUrl: VimeoBaseURL,
        accessToken: "912f18986c2801940312fb15daf5fbc1",
        apiVersion: "3.4")
    
    var vimeoClient: VimeoClient {
        return VimeoClient(appConfiguration: appConfiguration, sessionManager: sessionManager)
    }
    
    private var authenticationController: AuthenticationController {
        return AuthenticationController(client: vimeoClient, appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
    }
    
    // MARK: - Overrides for init
    private init() {
//        initialSetup()
    }
    
    // MARK: - Private functions
    private func initialSetup() {
        authenticationController.accessToken(token: "912f18986c2801940312fb15daf5fbc1") { result in
            switch result {
            case .success(let account):
                print("authenticated successfully: \(account)")
            case .failure(let error):
                print("failure authenticating: \(error)")
            }
        }
    }
    
    // MARK: - Public functions
    func requestHLSVideo(withId id: String, completion: @escaping (URL?) -> ()) {
        let videoRequest = Request<VIMVideo>(path: "/videos/\(id)")
        let _ = vimeoClient.request(videoRequest) { result in
            switch result {
            case .success(let response):
                let video: VIMVideo = response.model
                if let videoFiles = video.files as? [VIMVideoFile] {
                    // Will create redundancy if not only one link is returned
                    guard let link = videoFiles.first(where: { (file) -> Bool in
                        file.link!.contains(".m3u8")
                    })?.link else { return }
                    completion(URL(string: link))
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("error retrieving video: \(error)")
                completion(nil)
            }
        }
    }
}




