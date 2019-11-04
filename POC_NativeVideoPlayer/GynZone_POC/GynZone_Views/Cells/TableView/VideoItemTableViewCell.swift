//
//  VideoItemTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class VideoItemTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "VideoItemTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: - Override functions for views
    
    override func prepareForReuse() {
        self.progressBar.alpha = 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
        
        shadowView.layer.cornerRadius = 5
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = .symmetric(1)
    }
    
    // MARK: - Public functions
    func configureCell(title: String, timeString: String, progress: Float? = nil) {
        self.titleLabel.text = title
        self.timeLabel.text = timeString
        if progress != nil {
            progressBar.progress = progress!
        } else {
            progressBar.alpha = 0
        }
    }
}
