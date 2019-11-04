//
//  DetailedItemCollectionViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DetailedItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Static properties
    static let nibName = "DetailedItemCollectionViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    @IBOutlet weak var containerView: UIView!
    
    private var innerView: DetailedSingleItemView?

    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        innerView = UINib(nibName: DetailedSingleItemView.nibName, bundle: nil).instantiate(withOwner: self, options: nil).first as? DetailedSingleItemView
        contentView.addSubview(innerView!)
        innerView!.setupView()
        innerView!.snp.makeConstraints({ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        })
    }
    
    // MARK: - Public functions
    func configureCell(title: String, subtitle: String? = nil, withCategoryAndText category: String? = nil, withProgressAndAmount progress: Float? = nil, chaptersString chapters: String, totalHours hours: String) {
        
        innerView?.configureView(title: title, subtitle: subtitle, withCategoryText: category, withProgressAmount: progress, chaptersString: chapters, totalHours: hours)
    }
}
