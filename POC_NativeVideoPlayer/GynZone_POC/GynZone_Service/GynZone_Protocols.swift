//
//  GynZone_Protocols.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

protocol XibInstancedView {
    static var nibName: String { get }
}

protocol LoginDelegate {
    func shouldLogOut()
}
