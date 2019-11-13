//
//  Utils.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 30/09/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class Utils {
    static var podBundle: Bundle? {
        get {
            let podBundle = Bundle(for: Utils.self)
            if let url = podBundle.url(forResource: "VimeoPlayer", withExtension: "bundle"), let serviceBundle = Bundle(url: url) {
                return serviceBundle
            }
            return nil
        }
    }
    
    public enum IconImages: String {
        case ICON_PLAY = "icon_play"
        case ICON_PAUSE = "icon_pause"
        case ICON_BACKWARD = "icon_backward"
        case ICON_FORWARD = "icon_forward"
        case ICON_NEXT = "icon_next"
        case ICON_CLOSE = "icon_close"
        case ICON_FULLSCREEN = "icon_fullscreen"
        case ICON_FULLSCREEN_DISMISS = "icon_fullscreen_dismiss"
        case ICON_CHECKMARK = "icon_checkmark"
        case ICON_CIRCLE_SELECTED = "icon_circle_selected"
        case ICON_CIRCLE_NOT_SELECTED = "icon_circle_not_selected"
        
        public func getImage() -> UIImage? {
            if let image = UIImage(named: self.rawValue) {
                return image.withRenderingMode(.alwaysTemplate)
            } else {
                return UIImage(named: self.rawValue, in: Utils.podBundle!, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
