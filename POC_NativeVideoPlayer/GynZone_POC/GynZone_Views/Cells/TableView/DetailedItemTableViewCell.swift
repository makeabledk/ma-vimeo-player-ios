//
//  DetailedItemTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DetailedItemTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "DetailedItemTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    private var innerView: DetailedSingleItemView?
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        innerView = UINib(nibName: DetailedSingleItemView.nibName, bundle: nil).instantiate(withOwner: self, options: nil).first as? DetailedSingleItemView
        
        
        innerView!.setupView()
        contentView.addSubview(innerView!)
        innerView!.snp.makeConstraints({ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DEFAULT_INSET, bottom: 8, right: DEFAULT_INSET))
        })
    }
    
    // MARK: - Public functions
    func configureCell(title: String, subtitle: String? = nil, withCategoryText category: String? = nil, withProgressAmount progress: Float? = nil, chaptersString chapters: String, totalHours hours: String) {
        
        innerView?.configureView(title: title, subtitle: subtitle, withCategoryText: category, withProgressAmount: progress, chaptersString: chapters, totalHours: hours)
    }
    
}
