//
//  HorizontalCollectionViewTableViewCell.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

enum HorizontalCollectionViewStyle {
    case simple
    case detailed
    case goreLevel
}

class HorizontalCollectionViewTableViewCell: UITableViewCell {
    
    // MARK: Static properties
    static let nibName = "HorizontalCollectionViewTableViewCell"
    static var identifier: String { get { return self.nibName + "identifier" } }

    // MARK: - Components/Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    // MARK: - Properties
    var collectionViewItems = [TestItem]()
    var collectionViewGoreItems = ["","","","",""]
    var style = HorizontalCollectionViewStyle.simple
    
    // MARK: - Override functions for views
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: SingleItemCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: SingleItemCollectionViewCell.identifier)
        
        collectionView.register(UINib(nibName: DetailedItemCollectionViewCell.nibName,
                                      bundle: nil), forCellWithReuseIdentifier: DetailedItemCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: GoreLevelCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: GoreLevelCollectionViewCell.identifier)
    }
    
    // MARK: - Public functions
    func configureCollectionView(style: HorizontalCollectionViewStyle) {
        self.style = style

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        switch style {
        case .detailed:
            let height = UIScreen.main.bounds.width
            let width = height * 0.75
            
            layout.itemSize = CGSize(width: width, height: height)
            
        case .goreLevel:
            let size = (UIScreen.main.bounds.width - (DEFAULT_INSET * 1.30)) / 3
            layout.itemSize = .symmetric(size)
            layout.minimumInteritemSpacing = DEFAULT_INSET * 0.25
            collectionView.alwaysBounceHorizontal = collectionViewGoreItems.count > 3
        case .simple:
            let height = Utility.calculateCellHeight()
            
            layout.itemSize = CGSize(width: (height * 0.75) + DEFAULT_INSET, height: height)
            
        }
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: DEFAULT_INSET/2, bottom: 0, right: DEFAULT_INSET/2)
    }
    
}
 
// MARK: - Extensions UICollectionViewDataSource
extension HorizontalCollectionViewTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if style == .goreLevel {
            return collectionViewGoreItems.count
        }
        return collectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch style {
        case .detailed:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailedItemCollectionViewCell.identifier, for: indexPath) as? DetailedItemCollectionViewCell else { return UICollectionViewCell() }
            cell.configureCell(title: "Fødselslæsioner grad 2", subtitle: "I dette kursus vises best practice for behandling af fødselslæsioner grad 2. Kurset indeholder mater…materiale som kan virke stødende for ikke-fagpersoner, og vi anbefaler derfor at du ser det i omgivelser, der tillader diskretion.", chaptersString: "2 chapters", totalHours: "1:32:33")
            return cell
        case .simple:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleItemCollectionViewCell.identifier, for: indexPath) as? SingleItemCollectionViewCell else { return UICollectionViewCell() }
            return cell
        case .goreLevel:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoreLevelCollectionViewCell.identifier, for: indexPath) as? GoreLevelCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
    }
}

// MARK: - Extensions UICollectionViewDelegate
extension HorizontalCollectionViewTableViewCell: UICollectionViewDelegate {
    
}
