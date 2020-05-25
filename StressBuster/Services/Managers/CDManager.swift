//
//  CDManager.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/29/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit
import Foundation
import CoreData

public final class CDManager {
    // MARK: - Shared Instance
    static let shared = CDManager()
    
    // MARK: - Save User Data to CoreData
    func saveCurrentUserData(newUser: User) {
        // MARK: - App Delegate Instance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // MARK: - CD Context
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "UserProfile", in: context)
        let userProfile = NSManagedObject(entity: entity!, insertInto: context)
        
        userProfile.setValue(newUser.avatar, forKey: "avatar")
        userProfile.setValue(newUser.userId, forKey: "id")
        userProfile.setValue(newUser.firstName, forKey: "firstName")
        userProfile.setValue(newUser.lastName, forKey: "lastName")
        userProfile.setValue(newUser.lastName, forKey: "email")
        userProfile.setValue(newUser.phoneNumber, forKey: "phoneNumber")
        userProfile.setValue(newUser.deviceToken, forKey: "deviceToken")
        userProfile.setValue(newUser.friendsIds, forKey: "friends")
        userProfile.setValue(newUser.requestIds, forKey: "requests")
        
        do {
            try context.save()
        } catch let err as NSError {
            print("Core Data Error: \(err), \(err.localizedDescription)")
        }
    }
    
    func retrieveUserData() -> User? {
        // MARK: - App Delegate Instance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // MARK: - CD Context
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            let userProfiles = results as! [NSManagedObject]
            
            let firstName = userProfiles.first?.value(forKey: "firstName") as? String
            let lastName = userProfiles.first?.value(forKey: "lastName") as? String
            let email = userProfiles.first?.value(forKey: "email") as? String
            let id = userProfiles.first?.value(forKey: "id") as? String
            let token = userProfiles.first?.value(forKey: "deviceToken") as? String
            let phoneNumber = userProfiles.first?.value(forKey: "phoneNumber") as? String
            let avatar = userProfiles.first?.value(forKey: "avatar") as? String
            
            var friendsUserIds = [String]()
            if let friendsArr = userProfiles.first?.value(forKey: "friends") as? [String] {
                friendsUserIds.append(contentsOf: friendsArr)
            }
            
            var requestsUserIds = [String]()
            if let requestsArr = userProfiles.first?.value(forKey: "requests") as? [String] {
                requestsUserIds.append(contentsOf: requestsArr)
            }
            
            let userProfile = User(deviceToken: token, userId: id, firstName: firstName, lastName: lastName, email: email, avatar: avatar, phoneNumber: phoneNumber, friendsIds: friendsUserIds, requestIds: requestsUserIds)
            
            return userProfile
        } catch let err {
            print("Error: \(err) \(err.localizedDescription)")
        }
        
        return nil
    }
    
    func updateCurrentUserData(user: User) {
        // MARK: - App Delegate Instance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // MARK: - CD Context
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
        request.predicate = NSPredicate(format: "id = %@", user.userId ?? "")
        
        do {
            let results = try context.fetch(request)
            let userProfiles = results as! [NSManagedObject]
            
            userProfiles.first?.setValue(user.userId, forKey: "id")
            userProfiles.first?.setValue(user.firstName, forKey: "firstName")
            userProfiles.first?.setValue(user.lastName, forKey: "lastName")
            userProfiles.first?.setValue(user.lastName, forKey: "email")
            userProfiles.first?.setValue(user.phoneNumber, forKey: "phoneNumber")
            userProfiles.first?.setValue(user.avatar, forKey: "avatar")
            
            do {
                try context.save()
            } catch let err as NSError {
                print("Core Data Error: \(err), \(err.localizedDescription)")
            }
            
        } catch let err {
            print("Error: \(err) \(err.localizedDescription)")
        }
    }
}
