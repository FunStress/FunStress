//
//  HomeVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/23/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var contactBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contactBtn.setTitle("Contact Us", for: .normal)
    }
    
    @IBAction func startBtnPressed(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func contactDetailsBtnPressed(_ sender: UIButton) {
        self.contactBtn.setTitle("stressapp123@gmail.com", for: .normal)
    }
    
    @IBAction func rateAppBarBtnPressed(_ sender: UIBarButtonItem) {
        self.rateApp()
    }
    
    fileprivate func rateApp() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") else {
            return
        }
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
