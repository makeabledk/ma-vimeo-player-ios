//
//  GynZone_Extensions.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

extension IndexPath {
    public static var zero: IndexPath {
        get {
            return IndexPath(row: 0, section: 0)
        }
    }
}

extension Array where Element == IndexPath {
    public static var rowRange: (_ section: Int, _ from: Int , _ to: Int) -> [IndexPath] {
        get {
            return { section, from, to in
                var array = [IndexPath]()
                for row in from...to {
                    array.append(IndexPath(row: row, section: section))
                }
                return array
            }
        }
    }
}

extension CGSize {    
    public static var symmetric: (_ amount: CGFloat) -> CGSize {
        get {
            return { amount in return CGSize(width: amount, height: amount) }
        }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat? = 1.0) {
        if hex == "#clear" {
            self.init(red:0, green:0, blue:0, alpha:0)
        } else {
            let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let scanner = Scanner(string: hexString)
            if (hexString.hasPrefix("#")) {
                scanner.scanLocation = 1
            }
            var color: UInt32 = 0
            scanner.scanHexInt32(&color)
            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            let red   = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue  = CGFloat(b) / 255.0
            self.init(red:red, green:green, blue:blue, alpha:alpha!)
        }
    }
}


