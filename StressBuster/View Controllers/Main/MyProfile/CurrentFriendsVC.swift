//
//  CurrentFriendsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/18/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class CurrentFriendsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLbl: UILabel!

    // MARK: - Stored Properties
    var friendsProfiles = [Profile]()
    var selectedProfile: Profile!
    
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
}

extension CurrentFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friendsProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "currentFriendsCell", for: indexPath) as? CurrentFriendTVCell {
            
            let frndProfile = self.friendsProfiles[indexPath.row]
            cell.configureCell(frndProfile)
            
            cell.unfriendBtnPressed = { (selected) in
                self.selectedProfile = frndProfile
                let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
                let unfriendAlertVC = storyBoard.instantiateViewController(withIdentifier: "unfriendAlertVC") as! UnfriendAlertVC
                unfriendAlertVC.successMessage = "Are you sure you want to unfriend \(frndProfile.firstName ?? "") \(frndProfile.lastName ?? "") ?"
                unfriendAlertVC.delegate = self
                unfriendAlertVC.modalPresentationStyle = .overCurrentContext
                self.present(unfriendAlertVC, animated: true, completion: nil)
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

extension CurrentFriendsVC: UnfriendDelegate {
    func unfriendUser(_ success: Bool) {
        if (success) {
            FirebaseData.shared.unfriendCurrentUserFriend(userId: self.selectedProfile.id ?? "") { (success) in
                if (success) {
                    self.getFriendsList()
                } else {
                    self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                }
            }
        }
    }
}
