//
//  SignOutAlertVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 1/14/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class SignOutAlertVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var messageLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func yesBtnPressed(_ sender: UIButton) {
        FirebaseAuth.shared.signOut(onCompletion: { (success) in
            if (success) {
                UserDefaults.standard.removeObject(forKey: "UserID")
                self.presentLogin()
            } else {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            }
        })
    }
    
    @IBAction func noBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

