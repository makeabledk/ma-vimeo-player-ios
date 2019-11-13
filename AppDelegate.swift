//
//  AppDelegate.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 17/09/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit
import VimeoNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var logInDelegate: LoginDelegate?
    
    // Access token from Makeable account: 912f18986c2801940312fb15daf5fbc1
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        VimeoService.current.configure(apiVersion: "3.4", token: "TOKEN", clientIdentifier: "IDENTIFIER", clientSecret: "SECRET")
        
        let containerVC = ContainerViewController(nibName: ContainerViewController.nibName, bundle: nil)

        self.logInDelegate = containerVC
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = containerVC
        
        return true
    }
}

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

