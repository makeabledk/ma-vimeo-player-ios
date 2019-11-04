//
//  DetailedCourseViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class DetailedCourseViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "DetailedCourseViewController"

    // MARK: - Components/Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - Properties
    // Testing
    var currentItem = VideoItem(title: "2. Læringsmål", categoryText: nil, videoID: "360533402", progress: 0.0, imageURL: nil)
    var tableViewItemsForModal = [VideoItem(title: "3. Instrumenter", categoryText: nil, videoID: "355063478", progress: nil, imageURL: nil)]
    
    var tableViewItems = ["1. Introduktion": ["1. Velkommen", "2. Læringsmål", "3. Referencer", "4. Træning af kompetencer"], "2. Gør klar til sutur": ["1. Forberedelse", "2. Analgesi", "3. Instrumenter", "4. Supermaterialer og nåle"]]
    // Testing End
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: DetailedItemWithDescriptionTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DetailedItemWithDescriptionTableViewCell.identifier)
        tableView.register(UINib(nibName: VideoItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: VideoItemTableViewCell.identifier)
        // Do any additional setup after loading the view.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Extensions UITableViewDelegate
extension DetailedCourseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
        let view = Utility.createHeaderView(title: Array(tableViewItems.keys)[section - 1])
        view.backgroundColor = BackgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let vc = PlayerModalViewController(nibName: PlayerModalViewController.nibName, bundle: nil)
            vc.tableViewItems = self.tableViewItemsForModal
            vc.currentItem = self.currentItem
            vc.modalPresentationStyle = .overFullScreen
            self.tabBarController?.hidesBottomBarWhenPushed = true
            navigationController?.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        } 
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Extensions UITableViewDataSource
extension DetailedCourseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return tableViewItems[Array(tableViewItems.keys)[section - 1]]!.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.keys.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedItemWithDescriptionTableViewCell.identifier) as? DetailedItemWithDescriptionTableViewCell else { return UITableViewCell() }
            cell.configureCell(title: "Fødselslæsioner grad2", subtitle: "I dette kursus vises best practice for behandling af fødselslæsioner grad 2. Kurset indeholder mater…materiale som kan virke stødende for ikke-fagpersoner, og vi anbefaler derfor at du ser det i omgivelser, der tillader diskretion.", withProgressAmount: 0.73, chapterCount: "4 Chapters", totalHours: "1:32:33 hrs")
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoItemTableViewCell.identifier, for: indexPath) as? VideoItemTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = tableViewItems[Array(tableViewItems.keys)[indexPath.section - 1]]![indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Extensions UINavigationControllerDelegate
extension DetailedCourseViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            if toVC is PlayerModalViewController {
                return SlideUpPushAnimtor()
            } else {
                return .none
            }
        case .pop:
            if fromVC is PlayerModalViewController {
                return SlideDownPopAnimator()
            } else {
                return .none
            }
        default:
            return .none
        }
    }
    
}


