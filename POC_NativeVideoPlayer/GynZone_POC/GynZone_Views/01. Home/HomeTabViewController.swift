//
//  HomeTabViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit


class HomeTabViewController: UIViewController, XibInstancedView {
    
    // MARK: Static properties
    static var nibName: String = "HomeTabViewController"
    
    // MARK: - Components/Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.accessibilityLabel = "continue"
        }
    }
    
    // MARK: - Properties
    var tableViewItems = [TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem()]
    
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: SingleItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SingleItemTableViewCell.identifier)
        tableView.register(UINib(nibName: HorizontalCollectionViewTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: HorizontalCollectionViewTableViewCell.identifier)
    }
    
}

// MARK: - Extensions UITableViewDelegate
extension HomeTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return Utility.createHeaderView(title: section == 0 ? "Continue where you left" : "Featured courses")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Utility.calculateCellHeight() * (indexPath.row == 0 ? 1.0 : 1.05)
        } else {
            return UIScreen.main.bounds.width
        }
    }
}

// MARK: - Extensions UITableViewDataSource
extension HomeTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SingleItemTableViewCell.identifier) as? SingleItemTableViewCell else { return UITableViewCell() }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalCollectionViewTableViewCell.identifier) as? HorizontalCollectionViewTableViewCell else { return UITableViewCell() }
                cell.collectionViewItems = Array(tableViewItems.dropFirst())
                cell.configureCollectionView(style: .simple)
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalCollectionViewTableViewCell.identifier) as? HorizontalCollectionViewTableViewCell else { return UITableViewCell() }
            cell.configureCollectionView(style: .detailed)
            cell.collectionViewItems = Array(tableViewItems.dropFirst())
            return cell
        }
    }
}

