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
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    
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
        FirebaseData.shared.retrieveCurrentUserData { (user) in
            if let userDetails = user {
                self.userData = userDetails
                
                self.firstNameLbl.text = userDetails.firstName ?? ""
                self.lastNameLbl.text = userDetails.lastName ?? ""
                self.phoneNumberLbl.text = userDetails.phoneNumber ?? ""
                self.emailLbl.text = userDetails.email ?? ""
                
                if let avatarName = userDetails.avatar {
                    let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
                    let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
                    let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
                    self.avatarImgView.image = UIImage(named: hyphenReplaced)
                }
            }
        }
        self.logoutBtn.setImageAndTitle()
        self.deleteAccountBtn.setImageAndTitle()
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
        header.textLabel?.font = UIFont(name: "Poppins-Regular", size: 12)!
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    @IBAction func logoutOutBtnPressed(_ sender: UIButton) {
        self.presentLogOutAlert()
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: UIButton) {
        self.presentDeleteAccountAlert()
    }
}
