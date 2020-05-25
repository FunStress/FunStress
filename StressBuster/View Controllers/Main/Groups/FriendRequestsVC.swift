//
//  FriendRequestsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class FriendRequestsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLbl: UILabel!

    // MARK: - Friend Request Properties
    var users = [Profile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.isHidden = true
        self.warningLbl.isHidden = true
        
        FirebaseData.shared.getFriendRequests() { (users) in
            if let friends = users {
                var usersData = [Profile]()
                for id in friends {
                    FirebaseData.shared.retrieveDataWith(userId: id) { (profile) in
                        usersData.append(profile)
                        self.users = usersData
                        self.reloadTableView()
                    }
                }
            }
        }
        
        self.reloadTableView()
    }
    
    fileprivate func reloadTableView() {
        self.activityIndicator.isHidden = true
        if (self.users.count > 0) {
            self.warningLbl.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.warningLbl.isHidden = false
            self.tableView.isHidden = true
        }
        self.tableView.reloadData()
    }
}

// MARK: - TableView Delegate & DataSource
extension FriendRequestsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestsTVCell {
            
            let user = self.users[indexPath.row]
            cell.configureCell(user)
            
            cell.confirmBtnPressed = { (selected) in
                if (selected) {
                    FirebaseData.shared.confirmRequest(receiverUserId: user.id ?? "") { (onSuccess) in
                        if (onSuccess) {
                            FirebaseData.shared.deleteReceivedRequest(userId: user.id ?? "") { (deleted) in
                                if (deleted) {
                                    self.users = self.users.filter { ($0.phoneNumber ?? "") != (user.phoneNumber ?? "") }
                                    self.reloadTableView()
                                } else {
                                    self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                                }
                            }
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
