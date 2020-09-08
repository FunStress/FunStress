//
//  LoginRegisterVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let VERIFY_SEGUE = "toVerifySegue"
let COUNTRY_CODE_SEGUE = "toCountryCodeSegue"

class LoginRegisterVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var phoneNumberTxtFld: UITextField!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    // MAKR: - Stored Properties
    var isLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
        phoneNumberTxtFld.becomeFirstResponder()
    }
    
    fileprivate func configureUI() {
        if (isLogin) {
            self.title = "Login"
        } else {
            self.title = "Register"
        }
        self.nextBtn.setImageAndTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == VERIFY_SEGUE) {
            if let verifyVC = segue.destination as? VerifyCodeVC {
                verifyVC.isLogin = self.isLogin
            }
        } else if (segue.identifier == COUNTRY_CODE_SEGUE) {
            if let selectCountryTVC = segue.destination as? SelectCountryTVC {
                selectCountryTVC.delegate = self
            }
        }
    }
    
    @IBAction func countryCodeBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: COUNTRY_CODE_SEGUE, sender: nil)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        self.handleLogin()
    }
    
    fileprivate func handleLogin() {
        if let phoneNumber = self.phoneNumberTxtFld.text, !phoneNumber.isEmpty, let countryCodeLbl = self.countryCodeBtn.titleLabel, let countryCode = countryCodeLbl.text {
            let phoneNumberWithCountryCode = countryCode + phoneNumber
            UserDefaults.standard.set(phoneNumberWithCountryCode, forKey: "UserPhoneNumber")
            self.view.endEditing(true)
            
            if (phoneNumberWithCountryCode == "+10002223334") {
                let demoVerificationId = "123000"
                UserDefaults.standard.set(demoVerificationId, forKey: "AuthVerifyID")
                self.performSegue(withIdentifier: VERIFY_SEGUE, sender: nil)
            } else {
                FirebaseAuth.shared.sendVerificationCodeWith(phone: phoneNumberWithCountryCode) { (verificationId, error) in
                    if let err = error, err.localizedDescription != "" {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    }
                    
                    if let verifyId = verificationId, verifyId != "" {
                        UserDefaults.standard.set(verifyId, forKey: "AuthVerifyID")
                        self.performSegue(withIdentifier: VERIFY_SEGUE, sender: nil)
                    } else {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    }
                }
            }
        } else {
            self.presentErrorAlert(errorMessage: "Invalid Phone Number")
            return
        }
    }
}

extension LoginRegisterVC: SelectCountryDelegate {
    func didSelectedCountry(country: Country) {
        self.countryCodeBtn.setTitle(country.dialCode, for: .normal)
    }
}
