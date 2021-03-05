//
//  AddFriendsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/18/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol AddedNewFriendsDelegate: class {
    func addedNewFriends(userIds: [String])
}

class AddFriendsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Delegate
    weak var delegate: AddedNewFriendsDelegate?
    
    // MARK: - Stored Properties
    var alreadyExistsInGrp = [String]()
    var friends = [Profile]()
    var allFriends = [Profile]()
    var filteredFriends = [Profile]()
    var isSearching = false
    var selectedProfile: Profile!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.font = UIFont(name: "Montserrat-Medium", size: 15.0)!
        
        searchBar.showsCancelButton = false
        
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        self.sortAlreadyFrndsFromAllFrnds(sortedFrnds: alreadyExistsInGrp)
//        if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
//            FirebaseData.shared.retrieveCurrentUsersFriendsData { (userIds) in
//                if let friendsUserIds = userIds {
//                    self.sortAlreadyFrndsFromAllFrnds(sortedFrnds: friendsUserIds)
//                }
//            }
//        }
    }
    
    fileprivate func sortAlreadyFrndsFromAllFrnds(sortedFrnds: [String]) {
        FirebaseData.shared.retrieveDataWith(userIds: alreadyExistsInGrp) { (friendsData) in
            if (friendsData.count > 0) {
                self.allFriends.append(contentsOf: friendsData)
            }
            self.allFriends.append(contentsOf: ContactsHelper.shared.getProfilesFromContacts())
            self.tableView.reloadData()
        }
    }

    @IBAction func addFriendsBarBtnPressed(_ sender: UIBarButtonItem) {
        if (alreadyExistsInGrp.count > 0) {
            self.delegate?.addedNewFriends(userIds: self.alreadyExistsInGrp)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentErrorAlert(errorMessage: "Please add some friends to the group to save or go back!")
        }
    }
}

extension AddFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return self.filteredFriends.count
        }
        return self.allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendsContactsCell", for: indexPath) as? AddFriendsContactsTVCell {
            
            if (isSearching) {
                selectedProfile = self.filteredFriends[indexPath.row]
            } else {
                selectedProfile = self.allFriends[indexPath.row]
            }
            
            cell.configureCell(selectedProfile)
            
            if let userId = selectedProfile.id, self.alreadyExistsInGrp.contains(userId) {
                cell.addBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            } else {
                cell.addBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            }
            
            cell.addBtnPressed = { (success, selectedProfilePhoneNumber) in
                // +1 check
                var phoneNumberModified = ""
                if (selectedProfilePhoneNumber.contains("+1")) {
                    phoneNumberModified = selectedProfilePhoneNumber
                } else if (selectedProfilePhoneNumber.first == "1") {
                    phoneNumberModified = "+\(selectedProfilePhoneNumber)"
                } else {
                    phoneNumberModified = "+1\(selectedProfilePhoneNumber)"
                }
                
                if (success) {
                    FirebaseData.shared.checkIfUserExists(phoneNumber: phoneNumberModified) { (isExists) in
                        if (!isExists) {
                            self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
                        }
                        
                        FirebaseData.shared.retrieveDataWithPhoneNumber(userPhoneNumber: phoneNumberModified) { (users) in
                            if (users.count > 0) {
                                self.alreadyExistsInGrp.append(users[0].id ?? "")
                            } else {
                                self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
                            }
                        }
                    }
                } else {
                    FirebaseData.shared.retrieveDataWithPhoneNumber(userPhoneNumber: phoneNumberModified) { (users) in
                        if (users.count > 0) {
                            self.alreadyExistsInGrp = self.alreadyExistsInGrp.filter { $0 != (users[0].id ?? "") }
                        } else {
                            self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
                        }
                    }
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Montserrat-Medium", size: 15)!
        header.textLabel?.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        
        if (self.friends.count > 0) {
            switch (section) {
            case 0:
                header.textLabel?.text = "Group Members"
            case 1:
                header.textLabel?.text = "Contacts"
            default:
                debugPrint("No Sections")
            }
        } else {
            header.textLabel?.text = "Contacts"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension AddFriendsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filteredFriends = self.allFriends.filter{ ($0.firstName?.contains(searchText)) ?? false }
        } else {
            isSearching = false
            searchBar.showsCancelButton = false
        }
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, searchText != "" {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filteredFriends = self.allFriends.filter{ ($0.firstName?.contains(searchText)) ?? false }
        } else {
            isSearching = false
            searchBar.showsCancelButton = false
        }
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tableView.reloadData()
        searchBar.endEditing(true)
    }
}
