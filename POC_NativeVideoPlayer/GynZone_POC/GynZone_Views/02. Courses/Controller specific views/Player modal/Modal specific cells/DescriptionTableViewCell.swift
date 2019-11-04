//
//  DescriptionTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "DescriptionTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Public functions
    func configureCell(title: String, description: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
