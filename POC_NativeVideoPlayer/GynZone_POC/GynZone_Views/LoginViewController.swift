//
//  LoginViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 04/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

protocol LoginTransitionDelegate {
    func didInsertCode(of: String?)
    
    func didRequestCodeFor(newVC: LoginViewController)
}

// MARK: -
class LoginViewController: UIViewController {
    
    // MARK: Static properties
    static let nibName = "LoginViewController"
    
    // MARK: - Components/Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonView: UIView!
    
    // MARK: - Properties
    private var countryCodePrefixRange = 3
    private var countryCodePrefixString = "+45"
    private var phoneNumberRange = 8
    
    private var passwordRange = 6
    
    private var forPassword = false
    
    var loginDelegate: LoginTransitionDelegate?
    
    // MARK: - Override functions for views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        
        if forPassword {
            setupAsCodeRecipient()
            buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeInserted)))
        } else {
            buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendCode)))
        }
    }
    
    // MARK: - Private functions
    private func makePrefix() {
        let attributedString = NSMutableAttributedString(string: countryCodePrefixString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSMakeRange(0,countryCodePrefixRange))
        inputTextField.attributedText = attributedString
    }
    
    private func setupAsCodeRecipient() {
        self.titleLabel.text = "Indtast koden"
        self.subtitleLabel.text = "Det kan tage et par sekunder, før koden er fremme."
        
        inputTextField.placeholder = "Kode"
        inputTextField.isSecureTextEntry = true
    }
    
    // MARK: - ObjC Functions and IBActions
    @objc func sendCode() {
        let vc = LoginViewController(nibName: LoginViewController.nibName, bundle: nil)
        vc.forPassword = true
        vc.loginDelegate = self.loginDelegate
        
        self.parent?.addChild(vc)
        vc.view.layoutIfNeeded()
        
        vc.view.frame.size.height = self.view.frame.height
        vc.view.frame.size.width = self.view.frame.width
        
        UIView.transition(from: self.view, to: vc.view, duration: 0.5, options: .transitionFlipFromRight, completion: { _ in
            self.removeFromParent()
        })
        
        loginDelegate?.didRequestCodeFor(newVC: vc)
    }
    
    @objc func codeInserted() {
        inputTextField.resignFirstResponder()
        self.loginDelegate?.didInsertCode(of: inputTextField.text)
    }
}
// MARK: - Extensions
extension LoginViewController: UITextFieldDelegate {
    // MARK: Extension: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !forPassword {
            makePrefix()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !forPassword {
            textField.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            let protectedRange = NSMakeRange(0, countryCodePrefixRange)
            let intersection = NSIntersectionRange(protectedRange, range)
            
            if intersection.length > 0 {
                return false
            }
            
            if range.location + range.length >= (countryCodePrefixRange + phoneNumberRange) {
                return false
            }
            return true
        } else {
            if range.location >= passwordRange {
                return false
            }
            return true
        }
    }
}
