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
    
    // MARK: - Delegate
    weak var delegate: AddedNewFriendsDelegate?
    
    // MARK: - Stored Properties
    var alreadyExistsInGrp = [String]()
    var friends = [Profile]()
    var existsFrnds = [Profile]()
    var nonExistsFrnds = [Profile]()
    var allFriends = [Profile]()
    var newlyFriendsAdded = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
            FirebaseData.shared.retrieveCurrentUsersFriendsData { (userIds) in
                if let friendsUserIds = userIds {
                    self.sortAlreadyFrndsFromAllFrnds(sortedFrnds: friendsUserIds)
                }
            }
        }
    }
    
    fileprivate func sortAlreadyFrndsFromAllFrnds(sortedFrnds: [String]) {
        FirebaseData.shared.retrieveDataWith(userIds: sortedFrnds) { (friendsData) in
            self.friends = friendsData
            
            for friend in self.friends {
                if let userId = friend.id, self.alreadyExistsInGrp.contains(userId) {
                    self.existsFrnds.append(friend)
                    self.newlyFriendsAdded.append(userId)
                } else {
                    self.nonExistsFrnds.append(friend)
                }
            }
            
            self.allFriends.append(contentsOf: self.existsFrnds)
            self.allFriends.append(contentsOf: self.nonExistsFrnds)
            self.tableView.reloadData()
        }
    }

    @IBAction func addFriendsBarBtnPressed(_ sender: UIBarButtonItem) {
        if (newlyFriendsAdded.count > 0) {
            self.delegate?.addedNewFriends(userIds: self.newlyFriendsAdded)
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
        return self.allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendsCell", for: indexPath) as? AddFriendsTVCell {
            
            let profile = self.allFriends[indexPath.row]
            cell.configureCell(profile)
            
            if let userId = profile.id, self.alreadyExistsInGrp.contains(userId) {
                cell.addBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            } else {
                cell.addBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            }
            
            cell.addBtnPressed = { (selected) in
                if (selected) {
                    self.newlyFriendsAdded.append(profile.id ?? "")
                } else {
                    self.newlyFriendsAdded = self.newlyFriendsAdded.filter { $0 != (profile.id ?? "") }
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
