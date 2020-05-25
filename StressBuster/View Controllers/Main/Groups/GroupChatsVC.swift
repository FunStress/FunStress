//
//  GroupChatsVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let GROUP_DETAILS_SEGUE = "toGroupDetailsSegue"

class GroupChatsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningStkView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Stored Properties
    var groups = [Group]()
    var selectedGroup: Group!
    var isSearching = false
    var filterdGroups = [Group]()
    
    // MARK: - Notification Direction Group Name
    var notificationGroupName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
        
        let backgroundImgView = UIImageView(image: UIImage(named: "launchLogo"))
        backgroundImgView.contentMode = .scaleAspectFit
        tableView.backgroundView = backgroundImgView
        tableView.backgroundView?.alpha = 0.1
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        searchBar.showsCancelButton = false
        self.tableView.isHidden = true
        self.warningStkView.isHidden = true
        self.activityIndicator.isHidden = false
        
        FirebaseData.shared.getGroups { (groupsData) in
            self.groups = groupsData
            self.redirectNotificationGroup()
        }
    }
    
    fileprivate func redirectNotificationGroup() {
        if (self.notificationGroupName != "") {
            let notificationGroupIndex = groups.firstIndex { (group) -> Bool in
                (group.name ?? "") == self.notificationGroupName
            }
            if let groupIndex = notificationGroupIndex {
                self.selectedGroup = self.groups[groupIndex]
            }
            self.notificationGroupName = ""
            self.performSegue(withIdentifier: GROUP_DETAILS_SEGUE, sender: nil)
        }
        self.reloadData()
    }
    
    fileprivate func reloadData() {
        if (self.groups.count > 0) {
            self.tableView.isHidden = false
            self.warningStkView.isHidden = true
        } else {
            self.tableView.isHidden = true
            self.warningStkView.isHidden = false
        }

        self.tableView.reloadData()
        self.activityIndicator.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == GROUP_DETAILS_SEGUE) {
            if let groupVC = segue.destination as? GroupVC {
                groupVC.grpId = self.selectedGroup.id ?? ""
            }
        }
    }
}

extension GroupChatsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return self.filterdGroups.count
        }
        
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as? GroupTVCell {
            
            var group: Group!
            
            if (isSearching) {
                group = self.filterdGroups[indexPath.row]
            } else {
                group = self.groups[indexPath.row]
            }

            cell.configureCell(group)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        self.selectedGroup = group
        self.performSegue(withIdentifier: GROUP_DETAILS_SEGUE, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension GroupChatsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            isSearching = true
            searchBar.showsCancelButton = true
            self.filterdGroups = self.groups.filter{ ($0.name!.contains(searchText)) }
        } else {
            isSearching = false
            searchBar.showsCancelButton = false
        }
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if let searchText = searchBar.text, searchText != "" {
                isSearching = true
                searchBar.showsCancelButton = true
                self.filterdGroups = self.groups.filter{ ($0.name!.contains(searchText)) }
            } else {
                isSearching = false
                searchBar.showsCancelButton = false
            }
            self.tableView.reloadData()
            searchBar.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tableView.reloadData()
        searchBar.endEditing(true)
    }
}
