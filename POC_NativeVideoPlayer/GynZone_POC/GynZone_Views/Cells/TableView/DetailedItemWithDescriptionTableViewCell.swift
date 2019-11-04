//
//  DetailedItemWithDescriptionTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DetailedItemWithDescriptionTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "DetailedItemWithDescriptionTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }
    
    // MARK: - Components/Outlets
    private var innerView: DetailedSingleItemView! = (UINib(nibName: DetailedSingleItemView.nibName, bundle: nil).instantiate(withOwner: self, options: nil).first as! DetailedSingleItemView)
    
    @IBOutlet weak var detailedInnerViewContainerView: UIView!
    @IBOutlet weak var descriptionBackgroundView: UIView!
    
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionGradientView: UIView!
    @IBOutlet weak var ghostDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    private var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var expandContainer: UIView!
    @IBOutlet weak var expandIcon: UIImageView!
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [UIColor.clear.withAlphaComponent(0).cgColor, BackgroundColor.cgColor]
        descriptionGradientView.backgroundColor = .clear
        descriptionGradientView.layer.addSublayer(gradientLayer!)
        
        ghostDescriptionLabel.numberOfLines = 5
        
        descriptionContainerView.layer.cornerRadius = 10
        descriptionContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        innerView.setupView(withCorner: false, withShadow: false)
        detailedInnerViewContainerView.addSubview(innerView)
        innerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        descriptionContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expand)))
        expandContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expand)))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.gradientLayer?.frame = descriptionGradientView.bounds
    }
    
    // MARK: - Public functions
    func configureCell(title: String, subtitle: String? = nil, withCategoryText category: String? = nil, withProgressAmount progress: Float? = nil, chapterCount chapters: String, totalHours hours: String) {
        
        innerView?.configureView(title: title, subtitle: nil, withCategoryText: category, withProgressAmount: progress, chaptersString: chapters, totalHours: hours)
        descriptionLabel.text = subtitle
        ghostDescriptionLabel.text = subtitle
    }
    
    // MARK: - ObjC Functions and IBActions
    private var expanded = false
    
    @objc func expand() {
        self.expanded = !self.expanded
        (parentFocusEnvironment as? UITableView)?.beginUpdates()
        UIView.animate(withDuration: 0.3, animations: {
            self.expandIcon.isHighlighted = self.expanded
            self.descriptionGradientView.alpha = self.expanded ? 0 : 1
            self.ghostDescriptionLabel.numberOfLines = self.expanded ? 0 : 5
        })
        (parentFocusEnvironment as? UITableView)?.endUpdates()
    }
}
