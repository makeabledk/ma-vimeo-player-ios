//
//  DetailedSingleItemView.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DetailedSingleItemView: UIView {
    
    // MARK: Static properties
    static let nibName = "DetailedSingleItemView"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryTextLabel: UILabel!
    
    @IBOutlet weak var detailedTitleLabel: UILabel!
    @IBOutlet weak var detailedSubtitleLabel: UILabel!
    
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var chaptersLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var gradientView: UIView!
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = CAGradientLayer()
        gradientLayer!.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        gradientView.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLayer?.frame = gradientView.bounds
    }
    
    // MARK: - Public functions
    func configureView(title: String, subtitle: String? = nil, withCategoryText category: String? = nil, withProgressAmount progress: Float? = nil, chaptersString chapters: String, totalHours hours: String) {
        
        self.detailedTitleLabel.text = title
        self.detailedSubtitleLabel.text = subtitle
        
        chaptersLabel.text = chapters
        totalTimeLabel.text = hours
        
        
        
        if category != nil {
            categoryTextLabel.text = category
        } else {
            categoryContainer.alpha = 0
        }
        
        if progress != nil {
            progressBar.progress = progress!
            progressLabel.text = "\(progress! * 100)% complete"
        } else {
            progressContainer.alpha = 0
        }
        

    }
    
    func setupView(withCorner corners: Bool = true, withShadow shadows: Bool = true) {
        let radius: CGFloat = 5.0
        if corners {
            containerView.layer.cornerRadius = radius
            containerView.clipsToBounds = true
        }
        if shadows {
            shadowView.layer.cornerRadius = radius
            shadowView.layer.shadowOpacity = 0.4
            shadowView.layer.shadowOffset = .symmetric(2)
        }
    }
    
    

}
