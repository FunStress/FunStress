//
//  AppConfig.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/26/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation

public final class AppConfig {
    
    // MARK: - Shared Instance
    static let shared = AppConfig()
    
    public func initialConfigurations() {
        
        // MARK: - Retrive User Data from Database
        FirebaseData.shared.retrieveCurrentUserData() { (user) in
            if let userData = user {
                CDManager.shared.saveCurrentUserData(newUser: userData)
            }
        }
    }
}
