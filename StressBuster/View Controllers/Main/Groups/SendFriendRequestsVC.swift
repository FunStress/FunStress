//
//  SendFriendRequestsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class SendFriendRequestsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Stored Properties
    var contacts = [PhoneContact]()
    var filteredContacts = [PhoneContact]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.showsCancelButton = false
        self.contacts = ContactsHelper.shared.getContacts()
        
        if (self.contacts.count == 0) {
            self.warningLbl.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.warningLbl.isHidden = true
            self.tableView.isHidden = false
        }
        
        self.tableView.reloadData()
        self.activityIndicator.isHidden = true
    }
}

// MARK: - TableView Delegate & DataSource
extension SendFriendRequestsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return self.filteredContacts.count
        }
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as? ContactsTVCell {
            
            var contact: PhoneContact!
            
            if (isSearching) {
                contact = self.filteredContacts[indexPath.row]
            } else {
                contact = self.contacts[indexPath.row]
            }
            
            cell.configureCell(contact)
            
            cell.addBtnPressed = { (selected) in
                var phoneNumber = contact.phoneNumber
                print(phoneNumber)
                // MARK: - Add +1 if the phone number doesn't have
                if (!phoneNumber.contains("+1")) {
                    phoneNumber = "+1\(phoneNumber)"
                }
                
                if (selected && cell.addBtn.titleLabel?.text == "Add") {
                    FirebaseData.shared.sendRequest(receiverPhoneNumber: phoneNumber) { (success) in
                        if (success) {
                            cell.addBtn.setTitle("Requested", for: .normal)
                        } else {
                            self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
                        }
                    }
                } else if (!selected && cell.addBtn.titleLabel?.text == "Requested") {
                    FirebaseData.shared.deleteSentRequest(receiverPhoneNumber: phoneNumber) { (success) in
                        if (success) {
                            cell.addBtn.setTitle("Add", for: .normal)
                        } else {
                            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
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
        return 60.0
    }
}

extension SendFriendRequestsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filteredContacts = self.contacts.filter{ ($0.fullName.contains(searchText)) }
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
            self.filteredContacts = self.contacts.filter{ ($0.fullName.contains(searchText)) }
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
