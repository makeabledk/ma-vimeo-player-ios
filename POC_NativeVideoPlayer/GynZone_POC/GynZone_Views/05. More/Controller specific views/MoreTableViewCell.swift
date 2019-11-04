//
//  MoreTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
    
    static let nibName = "MoreTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicatorIconImage: UIImageView!
    
    // MARK: - Public functions
    func configureCell(title: String, iconImage: UIImage?, indicatorIconImage: UIImage?) {
        self.titleLabel.text = title
        self.iconImage.image = iconImage
        self.indicatorIconImage.image = indicatorIconImage
    }
}
