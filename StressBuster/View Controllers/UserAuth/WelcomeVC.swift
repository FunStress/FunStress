//
//  WelcomeVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let LOGIN_SEGUE = "logInSegue"
let REGISTER_NOW_SEGUE = "registerNowSegue"

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginRegisterVC = segue.destination as? LoginRegisterVC {
            if (segue.identifier == LOGIN_SEGUE) {
                loginRegisterVC.isLogin = true
            } else if (segue.identifier == REGISTER_NOW_SEGUE) {
                loginRegisterVC.isLogin = false
            }
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: LOGIN_SEGUE, sender: nil)
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: REGISTER_NOW_SEGUE, sender: nil)
    }
}
