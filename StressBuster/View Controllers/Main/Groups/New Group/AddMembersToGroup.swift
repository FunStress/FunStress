//
//  AddMembersToGroup.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/24/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol MembersAddedToGroupDelegate: class {
    func selectedMembers(_ userIds: [String])
}

class AddMembersToGroup: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Stored Properties
    var friendsProfiles = [Profile]()
    var addedFrndsToGrp = [String]()
    var filteredFriendsProfiles = [Profile]()
    var isSearching = false
    var selectedProfile: Profile!
    
    // MARK: - Delegate
    weak var delegate: MembersAddedToGroupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.font = UIFont(name: "Montserrat-Medium", size: 15.0)!
        
        searchBar.showsCancelButton = false
        
        self.reloadData()
    }
    
    fileprivate func reloadData() {
        self.friendsProfiles.append(contentsOf: ContactsHelper.shared.getProfilesFromContacts())
        
        if (self.friendsProfiles.count > 0)  {
            self.warningLbl.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.warningLbl.isHidden = false
            self.tableView.isHidden = true
        }
        self.tableView.reloadData()
        self.activityIndicator.isHidden = true
    }
    
    @IBAction func doneBarBtnPressed(_ sender: UIBarButtonItem) {
        if (self.addedFrndsToGrp.count == 0) {
            self.presentErrorAlert(errorMessage: "Please add members to group!")
            return
        }
        self.delegate?.selectedMembers(self.addedFrndsToGrp)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddMembersToGroup: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return self.filteredFriendsProfiles.count
        }
        return self.friendsProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addMemberToGroupCell", for: indexPath) as? AddMemberToGroupCell {
            
            if (isSearching) {
                selectedProfile = self.filteredFriendsProfiles[indexPath.row]
            } else {
                selectedProfile = self.friendsProfiles[indexPath.row]
            }
            
            cell.configureCell(selectedProfile)
            
            if let userId = selectedProfile.id, self.addedFrndsToGrp.contains(userId) {
                cell.addRemoveBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            } else {
                cell.addRemoveBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            }
            
            cell.addRemoveBtnPressed = { (success, selectedProfilePhoneNumber) in
                let profileId = self.friendsProfiles[indexPath.row].id ?? ""
                
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
                                self.addedFrndsToGrp.append(users[0].id ?? "")
                            } else {
                                self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
                            }
                        }
                    }
                } else {
                    FirebaseData.shared.retrieveDataWithPhoneNumber(userPhoneNumber: phoneNumberModified) { (users) in
                        if (users.count > 0) {
                            self.addedFrndsToGrp = self.addedFrndsToGrp.filter { $0 != users[0].id ?? ""}
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension AddMembersToGroup: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filteredFriendsProfiles = self.friendsProfiles.filter{ ($0.firstName?.contains(searchText)) ?? false }
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
            self.filteredFriendsProfiles = self.friendsProfiles.filter{ ($0.firstName?.contains(searchText)) ?? false }
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
