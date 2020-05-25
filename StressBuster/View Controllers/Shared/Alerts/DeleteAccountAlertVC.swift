//
//  DeleteAccountAlertVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/15/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit

class DeleteAccountAlertVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var messageLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func yesBtnPressed(_ sender: UIButton) {
        FirebaseData.shared.deleteUserData() { (success) in
            if (success) {
                UserDefaults.standard.removeObject(forKey: "UserID")                
                self.presentLogin()
            } else {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            }
        }
    }
    
    @IBAction func noBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
