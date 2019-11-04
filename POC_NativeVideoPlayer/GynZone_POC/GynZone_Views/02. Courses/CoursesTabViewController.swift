//
//  CoursesTabViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class CoursesTabViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "CoursesTabViewController"
    
    // MARK: - Components/Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - Properties
    var tableViewItems = [TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem(), TestItem()]
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "  "
        self.navigationItem.backBarButtonItem = backItem
        tableView.register(UINib(nibName: DetailedItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DetailedItemTableViewCell.identifier)
        tableView.register(UINib(nibName: HorizontalCollectionViewTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: HorizontalCollectionViewTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

// MARK: - Extensions UITableViewDelegate
extension CoursesTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return Utility.createHeaderView(title: section == 0 ? "Gore level" : "Courses")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return Utility.calculateCellHeight(aspectMultiplier: 0.67055) + DEFAULT_INSET
        } else {
            return UIScreen.main.bounds.width * 0.25 + (DEFAULT_INSET * 2)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let vc = DetailedCourseViewController(nibName: DetailedCourseViewController.nibName, bundle: nil)
            vc.title = "Course"
            vc.navigationItem.backBarButtonItem?.tintColor = .systemOrange
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Extensions UITableViewDataSource
extension CoursesTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : tableViewItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalCollectionViewTableViewCell.identifier, for: indexPath) as? HorizontalCollectionViewTableViewCell else { return UITableViewCell() }
            cell.configureCollectionView(style: .goreLevel)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedItemTableViewCell.identifier, for: indexPath) as? DetailedItemTableViewCell else { return UITableViewCell() }
            cell.configureCell(title: "Fødselslæsioner grad 2", subtitle: "I dette kursus vises best practice for behandling af fødselslæsioner grad 2. Kurset indeholder mater…materiale som kan virke stødende for ikke-fagpersoner, og vi anbefaler derfor at du ser det i omgivelser, der tillader diskretion.", withProgressAmount: 0.73, chaptersString: "2 chapters", totalHours: "1:32:33")
            return cell
        }
    }
}
