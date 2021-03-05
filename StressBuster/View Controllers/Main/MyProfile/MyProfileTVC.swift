//
//  MyProfileTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let PROFILE_EDIT_SEGUE = "toProfielEditSegue"

class MyProfileTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailAddressLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Stored Properties
    var userData: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        if let testUser = UserDefaults.standard.value(forKey: "TestUser") as? Bool, testUser {
            FirebaseData.shared.retrieveTestCurrentUserData { (user) in
                if let userDetails = user {
                    self.userData = userDetails
                    
                    let fullName = "\(userDetails.firstName ?? "") \(userDetails.lastName ?? "")"
                    self.fullNameLbl.text = fullName
                    self.emailAddressLbl.text = userDetails.email ?? ""
                    self.phoneNumberLbl.text = userDetails.phoneNumber ?? ""
                    
                    if let avatarName = userDetails.avatar {
                        let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
                        let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
                        let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
                        self.avatarImgView.image = UIImage(named: hyphenReplaced)
                    }
                }
            }
        } else {
            FirebaseData.shared.retrieveCurrentUserData { (user) in
                if let userDetails = user {
                    self.userData = userDetails
                    
                    let fullName = "\(userDetails.firstName ?? "") \(userDetails.lastName ?? "")"
                    self.fullNameLbl.text = fullName
                    self.emailAddressLbl.text = userDetails.email ?? ""
                    self.phoneNumberLbl.text = userDetails.phoneNumber ?? ""
                    
                    if let avatarName = userDetails.avatar {
                        let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
                        let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
                        let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
                        self.avatarImgView.image = UIImage(named: hyphenReplaced)
                    }
                }
            }
        }
        self.logoutBtn.setImageAndTitle()
        self.deleteAccountBtn.setImageAndTitle()
        
        if let appCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "v \(appCurrentVersion)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == PROFILE_EDIT_SEGUE) {
            if let profileEditTVC = segue.destination as? EditProfileTVC {
                profileEditTVC.userData = self .userData
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Montserrat-Medium", size: 15)!
        header.textLabel?.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        
        switch (section) {
        case 0:
            header.textLabel?.text = "Avatar & Full Name"
        case 1:
            header.textLabel?.text = "Email Address"
        case 2:
            header.textLabel?.text = "Phone Number"
        default:
            debugPrint("No Sections")
        }
    }
    
    @IBAction func logoutOutBtnPressed(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "TestUser")
        self.presentLogOutAlert()
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: UIButton) {
        self.presentDeleteAccountAlert()
    }
}
