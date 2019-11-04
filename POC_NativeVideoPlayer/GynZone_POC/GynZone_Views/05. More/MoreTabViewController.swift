//
//  MoreTabViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class MoreTabViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "MoreTabViewController"

    // MARK: - Components/Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: MoreTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MoreTableViewCell.identifier)
    }
}

// MARK: - Extensions UITableViewDelegate
extension MoreTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - Extensions UITableViewDataSource
extension MoreTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.identifier) as? MoreTableViewCell else { return UITableViewCell() }
        
        // TODO: cell.configure
        
        return cell
    }
    
    
}
