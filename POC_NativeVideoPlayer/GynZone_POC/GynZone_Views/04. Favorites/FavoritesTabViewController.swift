//
//  FavoritesTabViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 03/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class FavoritesTabViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "FavoritesTabViewController"

    // MARK: - Components/Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var titleContainerView: UIView!
    
    // MARK: - Properties
    var tableViewItems = ["1. Introduktion": ["1. Velkommen", "2. Læringsmål", "3. Referencer", "4. Træning af kompetencer"], "2. Gør klar til sutur": ["1. Forberedelse", "2. Analgesi", "3. Instrumenter", "4. Supermaterialer og nåle"]]
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: VideoItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: VideoItemTableViewCell.identifier)
        let titleView = Utility.createHeaderView(title: "Favorites")
        titleContainerView.addSubview(titleView)
        titleView.backgroundColor = BackgroundColor
        titleView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}

// MARK: - Extensions UITableViewDelegate
extension FavoritesTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Utility.createHeaderView(title: Array(tableViewItems.keys)[section], fontSize: 16)
        view.backgroundColor = BackgroundColor
        return view
    }
}

// MARK: - Extensions UITableViewDataSource
extension FavoritesTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems[Array(tableViewItems.keys)[section]]!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoItemTableViewCell.identifier) as? VideoItemTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = tableViewItems[Array(tableViewItems.keys)[indexPath.section]]![indexPath.row]
        
        return cell
    }
}
