//
//  VideoItem.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class VideoItem{
 
    var titleText: String
    var vimeoVideoID: String
    var categoryText: String?
    var progressInPercent: Double?
    var imageURL: URL?
    
    init(title: String, categoryText: String?, videoID: String, progress: Double?, imageURL: URL?) {
        self.titleText = title
        self.vimeoVideoID = videoID
        self.categoryText = categoryText
        self.progressInPercent = progress
        self.imageURL = imageURL
    }
}

struct TestItem: Codable {

}
