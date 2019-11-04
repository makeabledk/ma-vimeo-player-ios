//
//  SingleItemTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class SingleItemTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "SingleItemTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    private var innerView: SimpleItemView = UINib(nibName: SimpleItemView.nibName, bundle: nil).instantiate(withOwner: self, options: nil).first as! SimpleItemView

    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        contentView.addSubview(innerView)
        innerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DEFAULT_INSET, bottom: 8, right: DEFAULT_INSET))
        })
    }
    
    // MARK: - Public functions
    func configureCell(title: String, progress: Float) {
        innerView.configureView(title: title, progress: progress)
    }
    
    
}
