//
//  SingleItemCollectionViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class SingleItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Static properties
    static let nibName = "SingleItemCollectionViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }

    // MARK: - Components/Outlets
    @IBOutlet weak var containerView: UIView!
    
    private var innerView: SimpleItemView = UINib(nibName: SimpleItemView.nibName, bundle: nil).instantiate(withOwner: self, options: nil).first as! SimpleItemView
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.addSubview(innerView)

        innerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        })
    }
    
    // MARK: - Public functions
    func configureCell(title: String, progress: Float) {
        innerView.configureView(title: title, progress: progress)
    }
}
