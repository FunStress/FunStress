//
//  EditGroupTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let ADD_REMOVE_MEMBERS_SEGUE = "toAddRemoveMembersSegue"

class EditGroupTVC: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var groupMembersLbl: UILabel!
    
    // MARK: - Stored Properties
    var groupDetails: Group!
    var avatars = [NSDictionary]()
    var selectedAvatarName = ""
    var friends = [Profile]()
    var membersExistsInGrp = [String]()
    var newlyAddedFrnds = [String]()
    
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
        if let group = self.groupDetails {
            self.nameTxtFld.text = group.name
            self.descriptionTxtView.text = group.description
            self.descriptionTxtView.textColor = UIColor.black
            
            if let userAvatar = group.avatar {
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
            
            if let userIds = group.users {
                if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
                    self.membersExistsInGrp = userIds.filter { (String($0) != userId) }
                    self.membersExistsInGrp.append(contentsOf: newlyAddedFrnds)
                    
                    FirebaseData.shared.retrieveDataWith(userIds: self.membersExistsInGrp) { (friendsData) in
                        self.friends = friendsData
                        
                        let membersDetailsTxt = (self.membersExistsInGrp.count > 1) ? "\(self.friends.count) members exist" : "\(self.friends.count) member exist"
                        self.groupMembersLbl.text = membersDetailsTxt
                    }
                }
            }
        }
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
        if (segue.identifier == ADD_REMOVE_MEMBERS_SEGUE) {
            if let addFriendsVC = segue.destination as? AddFriendsVC {
                addFriendsVC.delegate = self
                addFriendsVC.alreadyExistsInGrp = self.membersExistsInGrp
            }
        }
    }
    
    @IBAction func saveGroupBarBtnPressed(_ sender: UIButton) {
        let errorMessage = self.validateDetails()
        if (errorMessage != "") {
            self.presentErrorAlert(errorMessage: errorMessage)
            return
        }
        
        if let grpName = self.nameTxtFld.text, let grpDescription = self.descriptionTxtView.text {
            if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
                self.newlyAddedFrnds.append(userId)
                let groupUserIds = Array(Set(self.newlyAddedFrnds))
                FirebaseData.shared.updateGroup(id: self.groupDetails.id ?? "", name: grpName, description: grpDescription, avatar: self.selectedAvatarName, users: groupUserIds) { (success, error) in
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
        
        if (self.membersExistsInGrp.count == 0) {
            return "Please add friends to Group !"
        }
        
        return ""
    }
    
    @IBAction func deleteGrpBtnPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
        let deleteGroupAlertVC = storyBoard.instantiateViewController(withIdentifier: "deleteGroupAlertVC") as! DeleteGroupAlertVC
        deleteGroupAlertVC.modalPresentationStyle = .overCurrentContext
        deleteGroupAlertVC.groupId = self.groupDetails.id ?? ""
        deleteGroupAlertVC.delegate = self
        self.present(deleteGroupAlertVC, animated: true, completion: nil)
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
                self.performSegue(withIdentifier: ADD_REMOVE_MEMBERS_SEGUE, sender: nil)
            }
        }
    }
}

// MARK: - Avatar CollectionView DataSource & Delegate
extension EditGroupTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == avatarCollectionView) {
            return self.avatars.count
        } else {
            return self.friends.count
        }
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

extension EditGroupTVC: DeleteGroupDelegate {
    func deleteGroup(_ success: Bool) {
        if (success) {
            self.presentHome()
        } else {
            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
        }
    }
}

extension EditGroupTVC: AddedNewFriendsDelegate {
    func addedNewFriends(userIds: [String]) {
        self.newlyAddedFrnds = userIds
    }
}

extension EditGroupTVC: UITextViewDelegate {
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
