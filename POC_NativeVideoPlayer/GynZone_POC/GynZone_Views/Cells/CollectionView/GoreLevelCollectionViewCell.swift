//
//  GoreLevelCollectionViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class GoreLevelCollectionViewCell: UICollectionViewCell {
    
    // MARK: Static properties
    static let nibName = "GoreLevelCollectionViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        shadowView.layer.cornerRadius = 5
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowOffset = CGSize(width: -1, height: 0)
        shadowView.layer.shadowRadius = 2
        
    }
    
    // MARK: - Public functions
    func configureCell(amountText: String, image: UIImage?) {
        self.amountLabel.text = amountText
        self.iconImageView.image = image
    }
}
