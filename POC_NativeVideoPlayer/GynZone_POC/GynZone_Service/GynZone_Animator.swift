//
//  GynZone_Animator.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 03/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SlideUpPushAnimtor: NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.3


    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
         guard let toView = transitionContext.view(forKey: .to) else { return }
        toView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        transitionContext.containerView.addSubview(toView)
        
        UIView.animate(withDuration: animationDuration, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class SlideDownPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.3


    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else { return }
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.addSubview(fromView)
        
        
        UIView.animate(withDuration: animationDuration, animations: {
            fromView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }) { completed in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


