//
//  VerifyCodeVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let DETAILS_SEGUE = "toDetailsSegue"

class VerifyCodeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var disclaimerLbl: UILabel!
    @IBOutlet weak var codeTxtFld: UITextField!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    // MARK: - Stored Properties
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
        
        if let phoneNumber = UserDefaults.standard.value(forKey: "UserPhoneNumber") as? String {
            self.disclaimerLbl.text = "Please enter the OTP sent to \(phoneNumber)"
        }
        
        // MARK: - Normal Text
        let mutableTitleString = NSMutableAttributedString()
        let normalText = NSAttributedString(string: "Didn't receive code? ", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0)!])
        
        let highlightedText = NSAttributedString(string: "Send Again", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1),  NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!])
        
        mutableTitleString.append(normalText)
        mutableTitleString.append(highlightedText)
        
        self.resendOTPBtn.setAttributedTitle(mutableTitleString, for: .normal)
        
        self.codeTxtFld.becomeFirstResponder()
        self.nextBtn.setImageAndTitle()
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        self.verifyOTPCode()
    }
    
    @IBAction func resendOTPBtnPressed(_ sender: UIButton) {
        guard let phoneNumber = UserDefaults.standard.value(forKey: "UserPhoneNumber") as? String else {
            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            return
        }
        
        FirebaseAuth.shared.sendVerificationCodeWith(phone: phoneNumber) { (verificationId, error) in
            if let err = error, err.localizedDescription != "" {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            }
            
            if let verifyId = verificationId, verifyId != "" {
                UserDefaults.standard.set(verifyId, forKey: "AuthVerifyID")
            } else {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            }
        }
    }
    
    fileprivate func verifyOTPCode() {
        guard let verifyCode = self.codeTxtFld.text, verifyCode != "" else {
            self.presentErrorAlert(errorMessage: "Please try agian")
            return
        }
        
        guard let verifyID = UserDefaults.standard.value(forKey: "AuthVerifyID") as? String, verifyID != "" else {
            self.presentErrorAlert(errorMessage: "Something went wrong, please try again")
            return
        }
        
        FirebaseAuth.shared.signInWith(verificationID: verifyID, verificationCode: verifyCode) { (error) in
            if (error != nil) {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                return
            }
            
            // MARK: - Remove Authentication Verification ID, will be of no use in future anymore
            UserDefaults.standard.removeObject(forKey: "AuthVerifyID")
            
            if (self.isLogin == false) {
                self.performSegue(withIdentifier: DETAILS_SEGUE, sender: nil)
            } else {
                // MARK: - Retrive User Data from Database
                FirebaseData.shared.retrieveCurrentUserData() { (user) in
                    if let userData = user {
                        CDManager.shared.saveCurrentUserData(newUser: userData)
                    }  else {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    }
                    
                    self.presentHome()
                }
            }
        }
    }
}
