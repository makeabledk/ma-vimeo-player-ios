//
//  GynZone_Utility.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class Utility {
    
    static func calculateCollectionViewHeight() -> CGFloat {
          return (calculateCellHeight() * 2) + (DEFAULT_INSET * 3)
      }
      
    static func calculateCellHeight(aspectMultiplier: CGFloat = SixteenToNineMultiplier) -> CGFloat {
          let screenWidth_noInset = UIScreen.main.bounds.width - (2 * DEFAULT_INSET)
          return screenWidth_noInset * aspectMultiplier
      }
    
    static func createHeaderView(title: String?, fontSize size: CGFloat = 24) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: size)
        label.text =  title
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        label.snp.makeConstraints({ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DEFAULT_INSET, bottom: 8, right: DEFAULT_INSET))
        })
        view.backgroundColor = BackgroundColor
        return view
    }
    
}
