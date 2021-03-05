//
//  EditProfileTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class EditProfileTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var firstNameTxtFld: UITextField!
    @IBOutlet weak var lastNameTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    // MARK: - Stored Properties
    var avatars = [NSDictionary]()
    var userData: User!
    var selectedAvatarName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag        
        self.avatarCollectionView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadAvatars()
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        if let user = self.userData {
            self.firstNameTxtFld.text = user.firstName ?? ""
            self.lastNameTxtFld.text = user.lastName ?? ""
            self.phoneNumberLbl.text = user.phoneNumber ?? ""
            self.emailTxtFld.text = user.email ?? ""
            
            if let userAvatar = user.avatar {
                for avatar in self.avatars {
                    if let avatarName = avatar["name"] as? String,
                        avatarName == userAvatar,
                        let index = self.avatars.firstIndex(of: avatar) {
                        self.selectedAvatarName = avatarName
                        let indexPath = IndexPath(item: index, section: 0)
                        self.avatarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
                        self.avatarCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                    }
                }
            }
        }
        
        self.saveBtn.setImageAndTitle()
    }
    
    private func loadAvatars() {
        if let url = Bundle.main.url(forResource: "Avatars", withExtension: "plist") {
            if let avatarsList = NSArray(contentsOf: url) as? [NSDictionary] {
                self.avatars = avatarsList
                self.avatarCollectionView.reloadData()
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
            header.textLabel?.text = "Avatar"
        case 1:
            header.textLabel?.text = "First Name"
        case 2:
            header.textLabel?.text = "Last Name"
        case 3:
            header.textLabel?.text = "Email Address"
        case 4:
            header.textLabel?.text = "Phone Number"
        default:
            debugPrint("No Sections")
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        let errorMessage = self.validateDetails()
        if (errorMessage != "") {
            self.presentErrorAlert(errorMessage: errorMessage)
            return
        }
        
        guard let phoneNumber = UserDefaults.standard.value(forKey: "UserPhoneNumber") as? String, phoneNumber != "" else {
            self.presentErrorAlert(errorMessage: "Something went wrong, please try again")
            return
        }
        
        FirebaseData.shared.retrieveCurrentUserData { (user) in
            if let userDetails = user {
                var frndsDict = [String: String]()
                var requestsDict = [String: String]()
                
                if let frndsValues = userDetails.friendsIds {
                    for frndId in frndsValues {
                        frndsDict[frndId] = frndId
                    }
                }
                
                if let requestValues = userDetails.requestIds {
                    for requestId in requestValues {
                        requestsDict[requestId] = requestId
                    }
                }
                
                let userDetailValues: [String: Any] = ["avatar": self.selectedAvatarName,
                                                       "deviceToken": userDetails.deviceToken ?? "",
                                                       "firstName": self.firstNameTxtFld.text ?? "",
                                                       "lastName": self.lastNameTxtFld.text ?? "",
                                                       "email": self.emailTxtFld.text ?? "",
                                                       "id": userDetails.userId ?? "",
                                                       "phoneNumber": userDetails.phoneNumber ?? "",
                                                       "requests": requestsDict,
                                                       "friends": frndsDict]
                
                FirebaseData.shared.updateCurrentUserData(userValues: userDetailValues) { (success) in
                    if (success) {
                        CDManager.shared.updateCurrentUserData(user: userDetails)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    }
                }
            }
        }
    }
    
    func validateDetails() -> String {
        if (selectedAvatarName == "") {
            return "Please select avatar !"
        }
        
        if let firstName = self.firstNameTxtFld.text, firstName.isEmpty {
            return "Invalid First Name !"
        }
        
        if let lastName = self.lastNameTxtFld.text, lastName.isEmpty {
            return "Invalid Last Name !"
        }
        
        if let email = self.emailTxtFld.text, email.isEmpty {
            return "Invalid Email !"
        }
        
        return ""
    }
}

// MARK: - Avatar CollectionView DataSource & Delegate
extension EditProfileTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = avatarCollectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as? AvatarCVCell {
            
            let avatar = self.avatars[indexPath.row]
            cell.configureAvatar(avatar)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAvatar = self.avatars[indexPath.row]
        self.selectedAvatarName = selectedAvatar["name"] as? String ?? ""
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 140.0)
    }
}
