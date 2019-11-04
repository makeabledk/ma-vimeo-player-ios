//
//  PlayerModalViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 02/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class PlayerModalViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "PlayerModalViewController"
    
    // MARK: - Components/Outlets
    @IBOutlet weak var playerViewContainer: UIView!
    var playerView: PlayerView?
    
    // MARK: - Properties
    var currentItem: VideoItem?
    var nextItem: VideoItem?
    var tableViewItems2 = ["360533402","355063478"]
    var tableViewItems = [VideoItem]()
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.register(UINib(nibName: VideoItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: VideoItemTableViewCell.identifier)
        tableView.register(UINib(nibName: DescriptionTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DescriptionTableViewCell.identifier)
        
        preparePlayerWith(id: currentItem!.vimeoVideoID, startTime: currentItem!.progressInPercent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Misc. overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Private functions
    private func preparePlayerWith(id: String, startTime: TimeInterval?) {
        if playerView != nil {
            playerView?.removeFromParent()
            playerView?.view.removeFromSuperview()
            playerView = nil
        }
        playerView = PlayerView(videoID: id, startPoint: startTime != nil ? startTime! : 0.0).setSkipInterval(with: 10.0).setHeadsUpTimer(amount: 5.0)
        
        DispatchQueue.main.async {
            self.playerViewContainer.addSubview(self.playerView!.view)
            self.playerView!.view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
            
            self.playerView!.dataSource = self
            self.playerView!.delegate = self
        }
    }
    
    // MARK: - ObjC Functions and IBActions
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
}

// MARK: - Extensions: UITableViewDelegate
extension PlayerModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= 1, tableViewItems.count > 0 {
            return Utility.createHeaderView(title: "Playing next", fontSize: 16)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= 1, tableViewItems.count > 0 {
            return 40
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            currentItem = tableViewItems[indexPath.row]
            nextItem = nil
            preparePlayerWith(id: tableViewItems[indexPath.row].vimeoVideoID, startTime: 0.0)
            if indexPath.row == tableViewItems.count {
                tableViewItems = [VideoItem]()
            } else {
                tableViewItems = Array(tableViewItems.suffix(from: indexPath.row + 1))
            }
            tableView.deleteRows(at: .rowRange(1, 0, indexPath.row), with: .automatic)
            if tableViewItems.count < 1 {
                tableView.reloadData()
            }
        } 
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Extensions: UITableViewDataSource
extension PlayerModalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section > 0 ? tableViewItems.count : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.identifier) as? DescriptionTableViewCell else { return UITableViewCell() }
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoItemTableViewCell.identifier) as? VideoItemTableViewCell else { return UITableViewCell() }
        let item = tableViewItems[indexPath.row]
        cell.configureCell(title: item.titleText, timeString: "02:42 min")
        return cell
    }
}

// MARK: - Extensions: PlayerViewDelegate
extension PlayerModalViewController: PlayerViewDelegate {
    func containerViewForPlayer() -> UIView {
        return playerViewContainer
    }
    
    func shouldPresentInFullscreenOver() -> UIViewController {
        return self
    }
    
    func timeStampUpdatedByIntevalOnVideo(withID id: String, newCurrentTime time: Double, duration: Double) {
        currentItem?.progressInPercent = time/duration
        // Write new timeStamp to DB
    }
    
    func shouldDismissPlayer() {
        self.playerView = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    func playingNextVideoInQueue(finishedVideoID oldID: String?, nextID id: String) {
        tableViewItems = Array(tableViewItems.dropFirst())
        currentItem = nextItem
        nextItem = nil
        tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        if tableViewItems.count < 1 {
            tableView.reloadData()
        }
    }
}

// MARK: - Extensions: PlayerViewDataSource
extension PlayerModalViewController: PlayerViewDataSource {
    func willFinishPlayingVideo(withID id: String) -> (id: String, startPoint: Double)? {
        if tableViewItems.count > 0 {
            let item = tableViewItems[0]
            nextItem = item
            return (item.vimeoVideoID, item.progressInPercent != nil ? item.progressInPercent! : 0.0)
        }
        return nil
    }
}
