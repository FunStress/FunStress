//
//  FirebaseAuth.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/20/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

public final class FirebaseAuth {
    
    // MARK: - Shared Instance
    static let shared = FirebaseAuth()
    
    // MARK: - Firebase Auth Instance
    let auth = Auth.auth()
    
    // MARK: - Verification Code to Input Phone Number
    func sendVerificationCodeWith(phone: String, onCompletion: @escaping(_ verificationId: String?, _ error: Error?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                onCompletion(nil, error)
            }
            
            return onCompletion(verificationID, nil)
        }
    }
    
    // MARK: - Sign In
    func signInWith(verificationID: String, verificationCode: String, onCompletion: @escaping( _ error: Error?) -> Void) {
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(error)
            }
            onCompletion(nil)
        }
    }
    
    // MARK: - Sign Out
    func signOut(onCompletion: @escaping(_ success: Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            onCompletion(true)
        } catch let err {
            onCompletion(false)
            print(err.localizedDescription)
        }
    }
    
    // MARK: - Delete User
    func deleteUser(onCompletion: @escaping(_ success: Bool) -> Void) {
        auth.currentUser?.delete(completion: { (error) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(false)
            }
            onCompletion(true)
        })
    }
}
