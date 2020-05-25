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
    
    // MARK: - Stored Properties
    var friendsProfiles = [Profile]()
    var addedFrndsToGrp = [String]()
    
    // MARK: - Delegate
    weak var delegate: MembersAddedToGroupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getFriendsList()
    }
    
    func getFriendsList() {
        FirebaseData.shared.getFriendsByUser() { (users) in
            if let friends = users {
                var friendsData = [Profile]()
                for id in friends {
                    FirebaseData.shared.retrieveDataWith(userId: id) { (profile) in
                        friendsData.append(profile)
                        self.friendsProfiles = friendsData
                        self.reloadData()
                    }
                }
            } else {
                self.friendsProfiles = []
                self.reloadData()
            }
            
            self.reloadData()
        }
    }
    
    fileprivate func reloadData() {
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
        self.friendsProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addMemberToGroupCell", for: indexPath) as? AddMemberToGroupCell {
            
            let frndProfile = self.friendsProfiles[indexPath.row]
            cell.configureCell(frndProfile)
            
            cell.addRemoveBtnPressed = { (selected) in
                let profileId = self.friendsProfiles[indexPath.row].id ?? ""
                if (selected) {
                    self.addedFrndsToGrp.append(profileId)
                } else {
                    self.addedFrndsToGrp = self.addedFrndsToGrp.filter { $0 != profileId }
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
