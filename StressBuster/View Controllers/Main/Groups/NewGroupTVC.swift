//
//  NewGroupTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let ADD_MEMBERS_TO_GROUP_SEGUE = "toAddMembersSegue"
class NewGroupTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    
    // MARK: - Input Outlets
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var friendsDetailsLbl: UILabel!
    
    // MARK: - Stored Properties
    var avatars = [NSDictionary]()
    var selectedAvatarName = ""
    var addedFrndsToGrp = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
        self.loadAvatars()
    }
    
    fileprivate func configureUI() {
        descriptionTxtView.text = "Describe the group..."
        descriptionTxtView.textColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.8039215686, alpha: 1)
        
        let friendsDetailsTxt = (self.addedFrndsToGrp.count > 1) ? "\(self.addedFrndsToGrp.count) friends added" : "\(self.addedFrndsToGrp.count) friend added"
        self.friendsDetailsLbl.text = friendsDetailsTxt
    }
    
    private func loadAvatars() {
        if let url = Bundle.main.url(forResource: "Avatars", withExtension: "plist") {
            if let avatarsList = NSArray(contentsOf: url) as? [NSDictionary] {
                self.avatars = avatarsList
                self.avatarCollectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == ADD_MEMBERS_TO_GROUP_SEGUE) {
            if let addMembersToGroupVC = segue.destination as? AddMembersToGroup {
                addMembersToGroupVC.delegate = self
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Poppins-Regular", size: 12)!
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StaticTVCell {
            if (cell.tag == 100) {
                self.performSegue(withIdentifier: ADD_MEMBERS_TO_GROUP_SEGUE, sender: nil)
            }
        }
    }
    
    @IBAction func saveGroupBtnPressed(_ sender: UIButton) {
        let errorMessage = self.validateDetails()
        if (errorMessage != "") {
            self.presentErrorAlert(errorMessage: errorMessage)
            return
        }
        
        if let grpName = self.nameTxtFld.text, let grpDescription = self.descriptionTxtView.text {
            if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
                self.addedFrndsToGrp.append(userId)
                FirebaseData.shared.createNewGroup(name: grpName, description: grpDescription, avatar: self.selectedAvatarName, users: self.addedFrndsToGrp) { (success, error) in
                    if (error != nil) {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    } else {
                        if (success) {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                        }
                    }
                }
            }
        }
    }
    
    func validateDetails() -> String {
        if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId == "" {
            return "You have logged out, please Login again to create a Group"
        }
        
        if (selectedAvatarName == "") {
            return "Please select a Group avatar !"
        }
        
        if let name = self.nameTxtFld.text, name.isEmpty {
            return "Invalid Group Name !"
        }
        
        if let description = self.descriptionTxtView.text, description == "Describe the group..." {
            return "Please enter some Group description !"
        }
        
        if (self.addedFrndsToGrp.count == 0) {
            return "Please add friends to Group !"
        }
        
        return ""
    }
}

// MARK: - Memebers Added to Group Delegate
extension NewGroupTVC: MembersAddedToGroupDelegate {
    func selectedMembers(_ userIds: [String]) {
        self.addedFrndsToGrp = userIds
    }
}

// MARK: - Avatar CollectionView DataSource & Delegate
extension NewGroupTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        if (collectionView == avatarCollectionView) {
            let selectedAvatar = self.avatars[indexPath.row]
            self.selectedAvatarName = selectedAvatar["name"] as? String ?? ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 140.0)
    }
}

extension NewGroupTVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor == #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.8039215686, alpha: 1)) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text.isEmpty) {
            textView.text = "Describe the group..."
            textView.textColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.8039215686, alpha: 1)
        }
    }
}