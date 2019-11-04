//
//  ContainerViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 07/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    static let nibName = "ContainerViewController"
    
    @IBOutlet weak var containerView: UIView!
    
    private var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForLogin()
    }
    
    func setupForLogin(withTransition: Bool = false) {
        
        let oldVC = currentVC
        
        self.currentVC = LoginViewController(nibName: LoginViewController.nibName, bundle: nil)
        
        (currentVC as? LoginViewController)?.loginDelegate = self
        self.addChild(currentVC!)
        
        currentVC!.view.frame.size.height = self.view.frame.height
        currentVC!.view.frame.size.width = self.view.frame.width
        if withTransition {
            self.currentVC?.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            self.containerView.addSubview(currentVC!.view)
            currentVC?.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.currentVC?.view.transform = CGAffineTransform.identity
            }, completion: { _ in
                oldVC?.removeFromParent()
                oldVC?.view.removeFromSuperview()
                self.view.layoutIfNeeded()
            })
            
        } else {
            self.containerView.addSubview(currentVC!.view)

        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
}

extension ContainerViewController: LoginDelegate {
    func shouldLogOut() {
//        self.currentVC?.removeFromParent()
        setupForLogin(withTransition: true)
    }
}

extension ContainerViewController: LoginTransitionDelegate {
    func didInsertCode(of: String?) {
        let oldVC = currentVC
        let tabVC = UITabBarController()
        let homeVC = HomeTabViewController(nibName: HomeTabViewController.nibName, bundle: nil)
        homeVC.tabBarItem.title = "Home"
        //TODO: TabIcon missing
        
        
        let coursesVC = CoursesTabViewController(nibName: CoursesTabViewController.nibName, bundle: nil)
        let coursesNavVC = UINavigationController(rootViewController: coursesVC)
        coursesNavVC.navigationBar.tintColor = .systemOrange
        coursesNavVC.tabBarItem.title = "Courses"
        //TODO: TabIcon missing
        coursesNavVC.setNavigationBarHidden(true, animated: false)
        
        let favoritesVC = FavoritesTabViewController(nibName: FavoritesTabViewController.nibName, bundle: nil)
        favoritesVC.tabBarItem.title = "Favorites"
        //TODO: TabIcon missing
        
        let moreVC = MoreTabViewController(nibName: MoreTabViewController.nibName, bundle: nil)
        moreVC.tabBarItem.title = "More"
        //TODO: TabIcon missing
        
        
        tabVC.viewControllers = [homeVC, coursesNavVC, favoritesVC, moreVC]
        tabVC.tabBar.tintColor = .systemOrange
        
        self.addChild(tabVC)
        self.currentVC = tabVC
        
        self.containerView.insertSubview(currentVC!.view, at: 0)
        
        UIView.animate(withDuration: 0.3, animations: {
            oldVC?.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }, completion: { _ in
            oldVC?.removeFromParent()
            oldVC?.view.removeFromSuperview()
        })
    }
    
    func didRequestCodeFor(newVC: LoginViewController) {
        self.currentVC = newVC
    }
    
    
}


