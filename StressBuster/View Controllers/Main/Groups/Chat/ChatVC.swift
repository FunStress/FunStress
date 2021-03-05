//
//  ChatVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let EDIT_GROUP_DETAILS_SEGUE = "toEditGroupDetailsSegue"
let EXPLORE_MUSIC_SEGUE = "toExploreMusicSegue"

class ChatVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tapMusicLbl: UILabel!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stressedView: UIView!
    @IBOutlet weak var stressedUserMsgLbl: UILabel!
    @IBOutlet weak var searchTextFld: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    
    // MARK: - Stored Properties
    var grpId = ""
    var groupDetails: Group!
    var contactDetails: PhoneContact!
    var chatProfile: Profile!
    var audioMessages = [AudioMessage]()
    var allMessages = [Message]()
    var selectedMessage: Message!
    var currentUserName = ""
    var isStressed = false
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let backgroundImgView = UIImageView(image: UIImage(named: "launchLogo"))
        backgroundImgView.contentMode = .scaleAspectFit
        tableView.backgroundView = backgroundImgView
        tableView.backgroundView?.alpha = 0.1
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    @objc func applicationDidBecomeActive() {
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.selectedMessage != nil) {
            SoundsHelper.shared.stopSound(urlString: self.selectedMessage.previewUrl)
        }
    }
    
    fileprivate func configureUI() {
        // MARK: - Get Current User full name
        FirebaseData.shared.retrieveCurrentUserData { (user) in
            if let userDetails = user {
                self.currentUserName = "\(userDetails.firstName ?? "") \(userDetails.lastName ?? "")"
            }
        }
        
        self.stressedView.isHidden = true
        self.tableView.isHidden = true
        self.warningLbl.isHidden = true
        self.tapMusicLbl.isHidden = true
        self.activityIndicator.isHidden = false
        
        if (grpId != "") {
            self.getCurrentGroupDetails(groupId: grpId)
        } else if let details = contactDetails {
            FirebaseData.shared.retrieveDataWithPhoneNumber(userPhoneNumber: details.phoneNumber) { (users) in
                if (users.count > 0) {
                    self.chatProfile = users[0]
                    self.warningLbl.isHidden = false
                    self.activityIndicator.isHidden = true
                    
                    let contactFullName = "\(self.chatProfile.firstName ?? "") \(self.chatProfile.lastName ?? "")"
                    if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
                        let groupFrnds = [userId, self.chatProfile.id ?? ""]
                        let currentUserFullName = "\(user.firstName ?? "") \(user.lastName ?? "")"
                        FirebaseData.shared.createNewGroupGetGroupId(name: "\(contactFullName)/\(currentUserFullName)", description: "", avatar: self.chatProfile.avatar ?? "", users: groupFrnds, isGroup: false) { (groupId, error) in
                            if (error != nil) {
                                self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                            } else {
                                self.grpId = groupId
                            }
                        }
                    }
                } else {
                    self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                }
            }
        }
    }
    
    fileprivate func getCurrentGroupDetails(groupId: String) {
        FirebaseData.shared.getGroupDetails(groupId: grpId) { (groupData) in
            self.groupDetails = groupData
            self.uploadDeviceTokens()
            
            if let group = self.groupDetails {
                self.title = group.name ?? ""
                self.grpId = group.id ?? ""
                
                if let isChatGroup = group.isGroup, !isChatGroup {
                    let deleteBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.deleteGroupBarButtonTapped))
                    self.navigationItem.rightBarButtonItems = [deleteBarButton]
                    
                    FirebaseData.shared.retrieveCurrentUserUID { (uid) in
                        if (uid != "") {
                            if let filteredUsers = group.users?.filter({ !$0.contains(uid) }) {
                                FirebaseData.shared.retrieveDataWith(userId: filteredUsers[0]) { (profile) in
                                    self.title = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
                                }
                            }
                        }
                    }
                } else {
                    let editBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "editIcon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.editGroupBarButtonTapped))
                    self.navigationItem.rightBarButtonItems = [editBarButton]
                }
                
                FirebaseData.shared.getChatAudioMessages(groupId: group.id ?? "") { (audioMessages) in
                    self.audioMessages = audioMessages
                    self.sortMessagesByTime()
                }
            }
        }
    }
    
    fileprivate func uploadDeviceTokens() {
        if let group = self.groupDetails {
            if let userIds = group.users {
                FirebaseData.shared.retrieveDataWith(userIds: userIds) { (friendsProfiles) in
                    var deviceTokens = [String]()
                    
                    for profile in friendsProfiles {
                        deviceTokens.append(profile.deviceToken ?? "")
                    }
                    
                    FirebaseData.shared.updateUsersDeviceTokenToGroup(groupId: group.id ?? "", tokens: deviceTokens)
                }
            }
        }
    }
    
    fileprivate func sortMessagesByTime() {
        var messages = [Message]()
        
        for audioMessage in self.audioMessages {
            let message = Message(track: audioMessage.track ?? "", artist: audioMessage.artist ?? "", previewUrl: audioMessage.previewUrl ?? "", artworkUrl: audioMessage.artworkUrl ?? "", sender: audioMessage.sender ?? "", timeStamp: audioMessage.timeStamp ?? Date())
            messages.append(message)
        }
        
        if (messages.count > 0) {
            self.allMessages = messages.sorted { $0.timeStamp < $1.timeStamp }
        } else {
            self.allMessages = messages
        }
        
        self.reloadData()
    }
    
    fileprivate func reloadData() {
        if (self.allMessages.count > 0) {
            self.tapMusicLbl.isHidden = false
            self.tableView.isHidden = false
            self.warningLbl.isHidden = true
        } else {
            self.tableView.isHidden = true
            self.warningLbl.isHidden = false
            self.tapMusicLbl.isHidden = true
        }

        self.handleStressed()
        tableView.reloadData()
        scrollToBottom()
        self.activityIndicator.isHidden = true
    }
    
    fileprivate func handleStressed() {
        var showStressedUser = false
        
        // MARK: - Check StressedUser timeStamp, if more than 8 hours then no Stressed User is displayed
        if let group = self.groupDetails {
            let calendar = Calendar.current
            let datehours = calendar.date(byAdding: .hour, value: -4, to: Date())
            let limitTime = datehours!.millisecondsSince1970
            let messageTime = Int64((group.timeStamp ?? 0))
            let eightHoursInMilliSeconds = 14400000
            let time = limitTime - messageTime
            showStressedUser = time < eightHoursInMilliSeconds
        }
        
        if (self.isStressed || ((self.groupDetails.stressedUser ?? "" != currentUserName) && showStressedUser)) {
            self.stressedView.isHidden = false
            self.stressedView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
            self.stressedUserMsgLbl.text = "\(self.groupDetails.stressedUser ?? "") is Stressed!"
            self.warningLbl.isHidden = true
        } else {
            self.stressedView.isHidden = true
            self.stressedUserMsgLbl.text = ""
            self.stressedView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if (self.allMessages.count > 0) {
                self.tableView.scrollToRow(at: IndexPath(item:self.allMessages.count-1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == EDIT_GROUP_DETAILS_SEGUE) {
            if let editGroupDetailsVC = segue.destination as? EditGroupTVC {
                editGroupDetailsVC.groupDetails = self.groupDetails
            }
        } else if (segue.identifier == EXPLORE_MUSIC_SEGUE) {
            if let exploreMusicVC = segue.destination as? SearchMusicVC {
                exploreMusicVC.searchString = self.searchTextFld.text ?? ""
                exploreMusicVC.delegate = self
            }
        }
    }
    
    @objc func editGroupBarButtonTapped() {
        performSegue(withIdentifier: EDIT_GROUP_DETAILS_SEGUE, sender: nil)
    }
    
    @objc func deleteGroupBarButtonTapped() {
        let storyBoard = UIStoryboard(name: "Alerts", bundle: nil)
        let deleteGroupAlertVC = storyBoard.instantiateViewController(withIdentifier: "deleteGroupAlertVC") as! DeleteGroupAlertVC
        deleteGroupAlertVC.modalPresentationStyle = .overCurrentContext
        deleteGroupAlertVC.groupId = self.groupDetails.id ?? ""
        deleteGroupAlertVC.delegate = self
        self.present(deleteGroupAlertVC, animated: true, completion: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        if let searchText = self.searchTextFld.text, searchText != "" {
            performSegue(withIdentifier: EXPLORE_MUSIC_SEGUE, sender: nil)
        } else {
            self.presentErrorAlert(errorMessage: "Search field cannot be empty, try searching with track or artist names.")
        }
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.allMessages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
            
            cell.configureCell(message)
            
            // MARK: - Configuring Sender/Receiver cell
            if (currentUserName == message.sender) {
                cell.senderLbl.textAlignment = .right
            } else {
                cell.senderLbl.textAlignment = .left
            }
            
            // MARK: - Playing the selected message cell music
            if (indexPath == self.selectedIndexPath) {
                self.selectedMessage = message
                if (cell.playImgView.isHidden) {
                    SoundsHelper.shared.playSound(urlString: message.previewUrl)
                    cell.playImgView.isHidden = false
                    cell.contentView.backgroundColor = UIColor.lightGray
                } else {
                    SoundsHelper.shared.stopSound(urlString: message.previewUrl)
                    cell.playImgView.isHidden = true
                    cell.contentView.backgroundColor = UIColor.clear
                }
            } else {
                cell.playImgView.isHidden = true
                cell.contentView.backgroundColor = UIColor.clear
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

extension ChatVC: AlertGroupDelegate {
    func alertGroup(success: Bool) {
        self.isStressed = success
        
        // MARK: - Update Stressed User to Group
        if (isStressed) {
            FirebaseData.shared.retrieveCurrentUserData { (user) in
                if let userDetails = user {
                    FirebaseData.shared.updateStressedUserToGroup(id: self.groupDetails.id ?? "", stressedUserName: self.currentUserName, senderDeviceToken: userDetails.deviceToken ?? "") { (success) in
                        if (success) {
                            self.handleStressed()
                        } else {
                            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                        }
                    }
                }
            }
        }
    }
}

extension ChatVC: SendMusicDelegate {
    func selected(music: Music) {
        let message = Message(track: music.track ?? "", artist: music.artist ?? "", previewUrl: music.previewUrl ?? "", artworkUrl: music.artworkUrl ?? "", sender: self.currentUserName, timeStamp: Date())
        
        FirebaseData.shared.retrieveCurrentUserData { (user) in
            if let userDetails = user {
                FirebaseData.shared.sendNewAudioMessage(groupId: self.grpId, audioMessage: message, senderDeviceToken: userDetails.deviceToken ?? "") { (success, error) in
                    if (error != nil || !success) {
                        self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                    }
                    
                    if (success) {
                        self.reloadData()
                    }
                }
            }
        }
    }
}

extension ChatVC: DeleteGroupDelegate {
    func deleteGroup(_ success: Bool) {
        if (success) {
            self.presentHome()
        } else {
            self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
        }
    }
}
