//
//  SubtitlePickerViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 09/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit
import PlayerKit

public class SubtitlePickerTableViewCell: UITableViewCell {
    static var identifier = "SubtitlePickerTableViewCellIdentifier"
    
    var iconImage = UIImageView()
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImage)
        contentView.addSubview(label)
        
        iconImage.snp.makeConstraints({ make in
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.left.equalToSuperview().inset(12)
            make.height.equalTo(26)
            make.width.equalTo(26)
        })
        
        label.snp.makeConstraints({ make in
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.right.equalToSuperview().inset(12)
            make.left.equalTo(iconImage.snp.right).inset(-4)
        })
        iconImage.tintColor = .black
        label.textAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class SubtitlePickerViewController: UIViewController {
    
    static let nibName = "SubtitlePickerViewController"
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    init() {
        super.init(nibName: type(of: self).nibName, bundle: Utils.podBundle)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerDelegate: PlayerView?
    var tableViewItems = [TextTrackMetadata]()
    var selectedItem: TextTrackMetadata?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.register(SubtitlePickerTableViewCell.self, forCellReuseIdentifier: SubtitlePickerTableViewCell.identifier)
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
        tableViewHeightConstraint.constant = CGFloat(Double(tableViewItems.count + 1) * 50.0)
        tableView.reloadData()
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerDelegate?.isPresenting = false
        playerDelegate?.startHideTimer()
    }
}

extension SubtitlePickerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= tableViewItems.count {
            playerDelegate?.player?.select(nil)
        } else {
            playerDelegate?.player?.select(tableViewItems[indexPath.row])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SubtitlePickerViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitlePickerTableViewCell.identifier) as? SubtitlePickerTableViewCell else { return UITableViewCell() }
        if indexPath.row < tableViewItems.count {
            
            let item = tableViewItems[indexPath.row]
            cell.label.text = item.displayName.replacingOccurrences(of: " SDH", with: "")
            if let selectedItem = selectedItem, item.displayName == selectedItem.displayName {
                cell.iconImage.image = Utils.IconImages.ICON_CIRCLE_SELECTED.getImage()
            } else {
                cell.iconImage.image = Utils.IconImages.ICON_CIRCLE_NOT_SELECTED.getImage()
            }
        }else {
            cell.label.text = "Ingen undertekster"
            if selectedItem == nil {
                cell.iconImage.image = Utils.IconImages.ICON_CIRCLE_SELECTED.getImage()
            } else {
                cell.iconImage.image = Utils.IconImages.ICON_CIRCLE_NOT_SELECTED.getImage()
            }
        }
        return cell
    }
}
