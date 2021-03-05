//
//  ContactsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit
import FirebaseAuth

let START_CHAT_SEGUE = "toStartChatSegue"

class ContactsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Stored Properties
    var contacts = [PhoneContact]()
    var filteredContacts = [PhoneContact]()
    var isSearching = false
    var selectedContact: PhoneContact!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.font = UIFont(name: "Montserrat-Medium", size: 15.0)!
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == START_CHAT_SEGUE) {
            if let chatVC = segue.destination as? ChatVC {
                chatVC.title = "\(self.selectedContact.firstName) \(self.selectedContact.lastName)"
                chatVC.contactDetails = self.selectedContact
            }
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
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
                                                                             
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isSearching) {
            self.selectedContact = self.filteredContacts[indexPath.row]
        } else {
            self.selectedContact = self.contacts[indexPath.row]
        }
        
        FirebaseData.shared.checkIfUserExists(phoneNumber: self.selectedContact.phoneNumber) { (isExists) in
            if (!isExists) {
                self.presentErrorAlert(errorMessage: "Your friend doesn't exist in our system, please ask your friend to Register Now!")
            }
            
            FirebaseData.shared.checkIfUserExistsReturnUid(phoneNumber: self.selectedContact.phoneNumber) { (userUid) in
                if (userUid != "") {
                    FirebaseData.shared.checkForPrivateChats(uid: userUid) { (exists) in
                        if (exists) {
                            self.presentErrorAlert(errorMessage: "There's been a chat opened already with your friend, please search in the Chats list!")
                        } else {
                            self.performSegue(withIdentifier: START_CHAT_SEGUE, sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension ContactsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filteredContacts = self.contacts.filter{ $0.firstName.contains(searchText) }
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
            self.filteredContacts = self.contacts.filter{ $0.firstName.contains(searchText) }
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
