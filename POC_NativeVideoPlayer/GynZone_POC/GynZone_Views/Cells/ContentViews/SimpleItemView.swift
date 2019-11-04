//
//  SimpleItemView.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class SimpleItemView: UIView {
    
    // MARK: Static properties
    static let nibName = "SimpleItemView"
    
    // MARK: - Components/Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    
    @IBOutlet weak var categoryTextLabel: UILabel!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoProgressBar: UIProgressView!

    @IBOutlet weak var gradientView: UIView!
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = CAGradientLayer()
        gradientLayer!.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        gradientView.layer.addSublayer(gradientLayer!)
        
        playImageView.layer.borderColor = UIColor.white.cgColor
        playImageView.layer.borderWidth = 2
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        shadowView.layer.cornerRadius = 5
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowOffset = .symmetric(2)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLayer?.frame = gradientView.bounds
    }

    // MARK: - Public functions
    func configureView(title: String, progress: Float) {
        self.videoTitleLabel.text = title
        self.videoProgressBar.progress = progress
    }
    
    
}
