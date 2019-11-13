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
    private var appConfiguration: AppConfiguration!
    
    private var sessionManager: VimeoSessionManager!
    
    var vimeoClient: VimeoClient {
        return VimeoClient(appConfiguration: appConfiguration, sessionManager: sessionManager)
    }
    
    private var authenticationController: AuthenticationController {
        return AuthenticationController(client: vimeoClient, appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
    }
    
    // MARK: - Overrides for init
    private init() {}
    
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
    
    public func configure(apiVersion: String, token: String, clientIdentifier: String, clientSecret: String) {
        do {
            guard try NSRegularExpression(pattern: "^(\\*|\\d+(\\.\\d+){0,2}(\\.\\d)?)$").matches(apiVersion) else { return }
            self.appConfiguration =  AppConfiguration(
                clientIdentifier: clientIdentifier, clientSecret: clientSecret,
                scopes: [.Public, .Private, .VideoFiles], keychainService: "KeychainServiceVimeo")
            
            self.sessionManager = VimeoSessionManager.defaultSessionManager(
                baseUrl: VimeoBaseURL,
                accessToken: token,
                apiVersion: apiVersion)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}




