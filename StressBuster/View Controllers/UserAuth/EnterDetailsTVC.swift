//
//  EnterDetailsTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class EnterDetailsTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var firstNameTxtFld: UITextField!
    @IBOutlet weak var lastNameTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var agreementsImgView: UIImageView!
    @IBOutlet weak var agreementsBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    
    // MARK: - Stored Properties
    var avatars = [NSDictionary]()
    var selectedAvatarName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCheckBoxTap))
        agreementsImgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCheckBoxTap() {
        if (agreementsImgView.image == UIImage(named: "uncheckboxIcon")) {
            agreementsImgView.image = UIImage(named: "checkboxIcon")
        } else {
            agreementsImgView.image = UIImage(named: "uncheckboxIcon")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.firstNameTxtFld.becomeFirstResponder()
        self.loadAvatars()
        self.agreementsImgView.image = UIImage(named: "uncheckboxIcon")
        
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont(name: "Poppins", size: 17.0)!,
            NSAttributedString.Key.foregroundColor : UIColor.black]

        let blueAttrs: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : UIFont(name: "Poppins", size: 17.0)!,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : 1]

        let attributedString = NSMutableAttributedString(string:"")

        let generalStr = NSMutableAttributedString(string: "I accept the ", attributes: attrs)
        let underlineStr = NSMutableAttributedString(string: "Agreements", attributes: blueAttrs)
        attributedString.append(generalStr)
        attributedString.append(underlineStr)
        agreementsBtn.setAttributedTitle(attributedString, for: .normal)
        
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
        header.textLabel?.font = UIFont(name: "Poppins-Regular", size: 12)!
        header.textLabel?.textColor = UIColor.lightGray
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
        
        FirebaseData.shared.saveCurrentUserData(firstName: self.firstNameTxtFld.text ?? "", lastName: self.lastNameTxtFld.text ?? "", email: self.emailTxtFld.text ?? "", avatar: self.selectedAvatarName, phoneNumber: phoneNumber) { (success, error) in
            if (error != nil) {
                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
            } else {
                if (success) {
                    FirebaseData.shared.retrieveCurrentUserData { (user) in
                        if let userData = user {
                            CDManager.shared.saveCurrentUserData(newUser: userData)
                        }
                        self.presentHome()
                    }
                } else {
                    self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
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
        
        if (agreementsImgView.image == UIImage(named: "uncheckboxIcon")) {
            return "Please accept the Terms & Conditions !"
        }
        
        return ""
    }
}

// MARK: - Avatar CollectionView DataSource & Delegate
extension EnterDetailsTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
