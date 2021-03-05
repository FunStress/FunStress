//
//  UIViewController+Extensions.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/16/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit

extension UIViewController {
    // MARK: - Navigation Back Button Empty Titles
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setUpTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    func presentLogin () {
        let storyBoard = UIStoryboard(name: "UserAuth", bundle: nil)
        let welcomeNVC: UINavigationController = (storyBoard.instantiateViewController(withIdentifier: "welcomeNVC") as? UINavigationController)!
        welcomeNVC.modalPresentationStyle = .fullScreen
        self.present(welcomeNVC, animated: true, completion: nil)
    }
    
    func presentHome() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC : UITabBarController = (storyBoard.instantiateViewController(withIdentifier: "homeTabBar") as? UITabBarController)!
        mainTabBarVC.modalPresentationStyle = .fullScreen
        mainTabBarVC.selectedIndex = 1
        self.present(mainTabBarVC, animated: true, completion: nil)
    }
    
    func presentDeleteAccountAlert() {
        let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
        let deleteAccountAlertVC = storyBoard.instantiateViewController(withIdentifier: "deleteAccountAlertVC") as! DeleteAccountAlertVC
        deleteAccountAlertVC.modalPresentationStyle = .overCurrentContext
        self.present(deleteAccountAlertVC, animated: true, completion: nil)
    }
    
    func presentLogOutAlert() {
        let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
        let signOutAlertVC = storyBoard.instantiateViewController(withIdentifier: "signOutAlertVC") as! SignOutAlertVC
        signOutAlertVC.modalPresentationStyle = .overCurrentContext
        self.present(signOutAlertVC, animated: true, completion: nil)
    }
    
    func presentErrorAlert(errorMessage: String) {
        let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
        let errorAlertVC = storyBoard.instantiateViewController(withIdentifier: "errorAlertVC") as! ErrorAlertVC
        errorAlertVC.errorMessage = errorMessage
        errorAlertVC.modalPresentationStyle = .overCurrentContext
        self.present(errorAlertVC, animated: true, completion: nil)
    }
}
