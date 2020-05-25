//
//  AppDelegate.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/15/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - Back Button Font Change
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 16.0)!], for: .normal)
        
        // MARK: - User Notification Permission
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
                if let err = error {
                    debugPrint(err.localizedDescription)
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()
        
        // MARK: - User Check
        if let user = Auth.auth().currentUser, user.uid != "" {
            if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
                if let userInfoDict = remoteNotification["aps"] as? NSDictionary {
                    if let alertDict = userInfoDict["alert"] as? Dictionary<String, String> {
                        if let messageBody = alertDict["body"] {
                            if (messageBody.contains("group")) {
                                let openReplaced = messageBody.replacingOccurrences(of: "Open ", with: "")
                                let extractedGroupName = openReplaced.replacingOccurrences(of: " group in Fun Stress now to send some music.", with: "")
                                self.presentNotificationGroupScreen(groupName: extractedGroupName)
                            } else if (messageBody.contains("requests")) {
                                print("Friend Request received !!!")
                            }
                        }
                    }
                }
            } else {
                self.presentHome()
            }
        } else {
            self.presentLogin()
        }
        
        AppConfig.shared.initialConfigurations()
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                debugPrint("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                FirebaseData.shared.uploadDeviceToken(deviceToken: result.token)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                debugPrint("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                FirebaseData.shared.uploadDeviceToken(deviceToken: result.token)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    // MARK: - Remote Notification received
    /* App is in the foreground */
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.updateBadgeCount()
        
        if let userInfoDict = notification.request.content.userInfo["aps"] as? NSDictionary {
            if let alertDict = userInfoDict["alert"] as? Dictionary<String, String> {
                if let messageBody = alertDict["body"] {
                    if (messageBody.contains("group")) {
                        let openReplaced = messageBody.replacingOccurrences(of: "Open ", with: "")
                        let extractedGroupName = openReplaced.replacingOccurrences(of: " group in Fun Stress now to send some music.", with: "")
                        self.presentNotificationGroupScreen(groupName: extractedGroupName)
                    } else if (messageBody.contains("requests")) {
                        print("Friend Request received !!!")
                    }
                }
            }
        }
        
        completionHandler([.alert, .badge, .sound])
    }
    
    /* App is in the background or closed */
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    fileprivate func showRemoteAlert(alertTitle: String, alertMessage: String, actionBtnTitle: String, window: UIWindow) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionBtnTitle, style: UIAlertAction.Style.default, handler: nil))
        window.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "StressBuster")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) { }
}

extension AppDelegate {
    fileprivate func presentLogin() {
        let storyBoard = UIStoryboard(name: "UserAuth", bundle: nil)
        let welcomeNVC: UINavigationController = (storyBoard.instantiateViewController(withIdentifier: "welcomeNVC") as? UINavigationController)!
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = welcomeNVC
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func presentHome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabBarVC: UITabBarController = (storyBoard.instantiateViewController(withIdentifier: "homeTabBar") as? UITabBarController)!
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeTabBarVC
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func presentNotificationGroupScreen(groupName: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabBarVC: UITabBarController = (storyBoard.instantiateViewController(withIdentifier: "homeTabBar") as? UITabBarController)!
        self.window = UIWindow(frame: UIScreen.main.bounds)
        homeTabBarVC.selectedIndex = 1
        self.window?.rootViewController = homeTabBarVC
        
        if let groupsNavigation = homeTabBarVC.viewControllers?[1] as? UINavigationController,
            let groupsVC = groupsNavigation.viewControllers.first as? GroupChatsVC {
            groupsVC.notificationGroupName = groupName
        }
            
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func presentRequestsScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabBarVC: UITabBarController = (storyBoard.instantiateViewController(withIdentifier: "homeTabBar") as? UITabBarController)!
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeTabBarVC
        
        if let groupsNavigation = homeTabBarVC.viewControllers?[1] as? UINavigationController,
            let groupsVC = groupsNavigation.viewControllers.first as? GroupChatsVC {
            
        }
            
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func updateBadgeCount() {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        if (badgeCount > 0) { badgeCount = badgeCount - 1 }
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
}
