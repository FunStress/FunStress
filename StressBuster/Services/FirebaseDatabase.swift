//
//  FirebaseDatabase.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/20/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

public final class FirebaseData {
    
    // MARK: - Shared Instance
    static let shared = FirebaseData()
    
    // MARK: - Firebase Database Instance
    let databaseRef = Database.database().reference()
    
    // MARK: - Save User to Database
    func saveCurrentUserData(firstName: String, lastName: String, email: String, avatar: String, phoneNumber: String, onCompletion: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false, nil)
            return
        }
        
        let userData: [String: Any] = ["id": userId,
                        "firstName": firstName,
                        "lastName": lastName,
                        "email": email,
                        "avatar": avatar,
                        "phoneNumber": phoneNumber]
        
        databaseRef.child("users").child(userId).setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                onCompletion(false, error)
            } else {
                onCompletion(true, nil)
            }
        }
    }
    
    // MARK: - Retrieve User Data from Database
    func retrieveCurrentUserData(onCompletion: @escaping(_ user: User?) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(nil)
            return
        }
        
        databaseRef.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let userId = value?["id"] as? String
            let token = value?["deviceToken"] as? String
            let firstName = value?["firstName"] as? String
            let lastName = value?["lastName"] as? String
            let email = value?["email"] as? String
            let phoneNumber = value?["phoneNumber"] as? String
            let avatar = value?["avatar"] as? String
            
            var friendsUserIds = [String]()
            if let friendsDict = value?["friends"] as? [String: String] {
                for (_, friendsUserId) in friendsDict {
                    friendsUserIds.append(friendsUserId)
                }
            }
            
            var requestsUserIds = [String]()
            if let requestsDict = value?["requests"] as? [String: String] {
                for (_, requestUserId) in requestsDict {
                    requestsUserIds.append(requestUserId)
                }
            }
            
            let userData = User(deviceToken: token, userId: userId, firstName: firstName, lastName: lastName, email: email, avatar: avatar, phoneNumber: phoneNumber, friendsIds: friendsUserIds, requestIds: requestsUserIds)
            
            onCompletion(userData)
        }
    }
    
    // MARK: - Retrieve test User Data from Database
    func retrieveTestCurrentUserData(onCompletion: @escaping(_ user: User?) -> Void) {
        databaseRef.child("users").child("5fG9jT111LRxu7000GrV898Ryw12").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let userId = value?["id"] as? String
            let token = value?["deviceToken"] as? String
            let firstName = value?["firstName"] as? String
            let lastName = value?["lastName"] as? String
            let email = value?["email"] as? String
            let phoneNumber = value?["phoneNumber"] as? String
            let avatar = value?["avatar"] as? String
            
            var friendsUserIds = [String]()
            if let friendsDict = value?["friends"] as? [String: String] {
                for (_, friendsUserId) in friendsDict {
                    friendsUserIds.append(friendsUserId)
                }
            }
            
            var requestsUserIds = [String]()
            if let requestsDict = value?["requests"] as? [String: String] {
                for (_, requestUserId) in requestsDict {
                    requestsUserIds.append(requestUserId)
                }
            }
            
            let userData = User(deviceToken: token, userId: userId, firstName: firstName, lastName: lastName, email: email, avatar: avatar, phoneNumber: phoneNumber, friendsIds: friendsUserIds, requestIds: requestsUserIds)
            
            onCompletion(userData)
        }
    }
    
    // MARK: - Retrive User Data with userId from Database
    func retrieveDataWith(userId: String, onCompletion: @escaping(_ user: Profile) -> Void) {
        databaseRef.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let userId = value?["id"] as? String
            let token = value?["deviceToken"] as? String
            let firstName = value?["firstName"] as? String
            let lastName = value?["lastName"] as? String
            let email = value?["email"] as? String
            let phoneNumber = value?["phoneNumber"] as? String
            let avatar = value?["avatar"] as? String
            
            let profile = Profile(id: userId, deviceToken: token, firstName: firstName, lastName: lastName, email: email, avatar: avatar, phoneNumber: phoneNumber)
            onCompletion(profile)
        }
    }
    
    // MARK: - Retrieve Users Data with userIds from Database
    func retrieveDataWith(userIds: [String], onCompletion: @escaping(_ user: [Profile]) -> Void) {
        databaseRef.child("users").observeSingleEvent(of: .value) { (snapshot) in
            var users = [Profile]()
            if let usersDict = snapshot.value as? NSDictionary {
                for (id, userDict) in usersDict {
                    if let userId = id as? String, userIds.contains(userId) {
                        if let userData = userDict as? NSDictionary {
                            let userId = userData["id"] as? String
                            let token = userData["deviceToken"] as? String
                            let firstName = userData["firstName"] as? String
                            let lastName = userData["lastName"] as? String
                            let email = userData["email"] as? String
                            let phoneNumber = userData["phoneNumber"] as? String
                            let avatar = userData["avatar"] as? String
                            
                            let profile = Profile(id: userId, deviceToken: token, firstName: firstName, lastName: lastName, email: email, avatar: avatar, phoneNumber: phoneNumber)
                            users.append(profile)
                        }
                    }
                }
            }
            onCompletion(users)
        }
    }
    
    // MARK: - Retrieve Current User's Friends Data
    func retrieveCurrentUsersFriendsData(onCompletion: @escaping(_ userIds: [String]?) -> Void) {
        guard let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" else {
            onCompletion(nil)
            return
        }
        
        databaseRef.child("users").child(userId).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            var userIds = [String]()
            if let friendsDict = snapshot.value as? NSDictionary {
                for (friendsUserId, _) in friendsDict {
                    if let userId = friendsUserId as? String {
                        userIds.append(userId)
                    }
                }
            }
            onCompletion(userIds)
        }
    }
    
    // MARK: - Update User data
    func updateCurrentUserData(userValues: [String: Any], onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        databaseRef.child("users").child(userId).updateChildValues(userValues)
        onCompletion(true)
    }
    
    //MARK: - Update Device Token to Current User's Database
    func uploadDeviceToken(deviceToken: String) {
        guard let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" else {
            return
        }
        
        databaseRef.child("users").child(userId).updateChildValues(["deviceToken": deviceToken])
    }
    
    // MARK: - Delete Current User Data from Database
    func deleteUserData(onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        let userRef = databaseRef.child("users").child(userId)
        
        userRef.removeValue { (error, _) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(false)
            }
            
            onCompletion(true)
        }
    }
    
    // MARK: - Send Friend Request to User and Receiver Database
    func sendRequest(receiverPhoneNumber: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        self.isUserPresent(phoneNumber: receiverPhoneNumber) { (id) in
            if let userId = id, !userId.isEmpty {
                self.databaseRef.child("users").child(userId).child("requests").child(userId).setValue(userId)
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        }
    }
    
    // MARK: - Confirm Friend Request
    func confirmRequest(receiverUserId: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
         
        databaseRef.child("users").child(receiverUserId).child("friends").child(userId).setValue(userId) {
            (error:Error?, ref:DatabaseReference) in
            if (error == nil) {
                self.databaseRef.child("users").child(userId).child("friends").child(receiverUserId).setValue(receiverUserId)
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        }
    }
    
    // MARK: - Delete Friend Request
    func deleteSentRequest(receiverPhoneNumber: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        self.isUserPresent(phoneNumber: receiverPhoneNumber) { (id) in
            if let userId = id, !userId.isEmpty {
                let senderRequestRef = self.databaseRef.child("users").child(userId).child("requests").child(userId)
                
                senderRequestRef.removeValue { (error, _) in
                    if let err = error, err.localizedDescription != "" {
                        onCompletion(false)
                    }
                    onCompletion(true)
                }
            } else {
                onCompletion(false)
            }
        }
    }
    
    // MARK: - Delete Friend Request
    func deleteReceivedRequest(userId: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        let senderRequestRef = self.databaseRef.child("users").child(userId).child("requests").child(userId)
        
        senderRequestRef.removeValue { (error, _) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(false)
            }
            onCompletion(true)
        }
    }
    
    // MARK: - Check if User Exists
    fileprivate func isUserPresent(phoneNumber: String, onCompletion: @escaping(_ userId: String?) -> Void) {
        databaseRef.child("users").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var userID = ""
            if let usersDict = snapshot.value as? NSDictionary {
                for (_, userValue) in usersDict {
                    if let userDict = userValue as? NSDictionary,
                        let id = userDict["id"] as? String,
                        let userPhoneNumber = userDict["phoneNumber"] as? String,
                        userPhoneNumber == phoneNumber {
                        userID = id
                    }
                }
            }
            onCompletion(userID)
        }
    }
    
    // MARK: - Retrieve Friends With UserId
    func getFriendsByUser(onCompletion: @escaping(_ userIds: [String]?) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(nil)
            return
        }
        
        self.databaseRef.child("users").child(userId).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            var friends = [String]()
            if let friendsDict = snapshot.value as? NSDictionary {
                for (_, friendsUserId) in friendsDict {
                    if let friendId = friendsUserId as? String {
                        friends.append(friendId)
                    }
                }
            }
            onCompletion(friends)
        }
    }
    
    // MARK: - Delete Friend by User Id
    func unfriendCurrentUserFriend(userId: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(false)
            return
        }
        
        let currentUserRef = self.databaseRef.child("users").child(userId).child("friends").child(userId)
        
        currentUserRef.removeValue { (error, _) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(false)
            }
            
            let currentUserFreindsRef = self.databaseRef.child("users").child(userId).child("friends").child(userId)
            
            currentUserFreindsRef.removeValue { (error, _) in
                if let err = error, err.localizedDescription != "" {
                    onCompletion(false)
                }
                onCompletion(true)
            }
        }
    }
    
    // MARK: - Retrieve Friend Requests By UserId
    func getFriendRequests(onCompletion: @escaping(_ userIds: [String]?) -> Void) {
        guard let currentUser = CDManager.shared.retrieveUserData(), let userId = currentUser.userId, userId != "" else {
            onCompletion(nil)
            return
        }
        
        self.databaseRef.child("users").child(userId).child("requests").observeSingleEvent(of: .value) { (snapshot) in
            var friends = [String]()
            if let requestsDict = snapshot.value as? NSDictionary {
                for (_, statusValue) in requestsDict {
                    if let userId = statusValue as? String {
                        friends.append(userId)
                    }
                }
            }
            onCompletion(friends)
        }
    }
    
    // MARK: - Create New Group
    func createNewGroup(name: String, description: String, avatar: String, users: [String], onCompletion: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        let userData: [String: Any] = ["name": name,
                                       "description": description,
                                       "avatar": avatar,
                                       "users": users]
        
        databaseRef.child("groups").childByAutoId().setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                onCompletion(false, error)
            } else {
                onCompletion(true, nil)
            }
        }
    }
    
    // MARK: - Update existing Group
    func updateGroup(id: String, name: String, description: String, avatar: String, users: [String], onCompletion: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        databaseRef.child("groups").child(id).updateChildValues(["name": name, "description": description, "avatar": avatar, "users": users])
        
        onCompletion(true, nil)
    }
    
    // MARK: - Get Groups
    func getGroups(onCompletion: @escaping(_ groups: [Group]) -> Void) {
        guard let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" else {
            return
        }
        
        self.databaseRef.child("groups").observeSingleEvent(of: .value) { (snapshot) in
            var groups = [Group]()
            if let groupsDict = snapshot.value as? NSDictionary {
                for (key, valueDict) in groupsDict {
                    if let usersDict = valueDict as? NSDictionary, let groupId = key as? String {
                        for (_, userIds) in usersDict {
                            if let idsArr = userIds as? [String] {
                                if (idsArr.contains(userId)) {
                                    let groupName = usersDict["name"] as? String
                                    let groupDescription = usersDict["description"] as? String
                                    let avatarName = usersDict["avatar"] as? String
                                    
                                    var stressedUser = ""
                                    var timeStamp: Int64 = 0
                                    if let stressedUserInfo = usersDict["stressedUser"] as? NSDictionary {
                                        stressedUser = stressedUserInfo["stressedUser"] as? String ?? ""
                                        timeStamp = stressedUserInfo["timeStamp"] as? Int64 ?? 0
                                    }
                                    
                                    let groupData = Group(id: groupId, name: groupName, description: groupDescription, avatar: avatarName, stressedUser: stressedUser, timeStamp: timeStamp, users: idsArr)
                                    groups.append(groupData)
                                }
                            }
                        }
                    }
                }
            }
            onCompletion(groups)
        }
    }
    
    // MARK: - Update Stressed User Value to Group
    func updateStressedUserToGroup(id: String, stressedUserName: String, senderDeviceToken: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        let stressedUserValues: [String: Any] = ["stressedUser": stressedUserName,
                                 "timeStamp": Date().millisecondsSince1970,
                                 "senderDeviceToken": senderDeviceToken]
        databaseRef.child("groups").child(id).child("stressedUser").updateChildValues(stressedUserValues)
        onCompletion(true)
    }
        
    // MARK: - Get Group Details by GroupId
    func getGroupDetails(groupId: String, onCompletion: @escaping(_ groups: Group) -> Void) {
        self.databaseRef.child("groups").child(groupId).observeSingleEvent(of: .value) { (snapshot) in
            if let groupDict = snapshot.value as? NSDictionary {
                let groupName = groupDict["name"] as? String
                let groupDescription = groupDict["description"] as? String
                let avatarName = groupDict["avatar"] as? String
                let idsArr = groupDict["users"] as? [String]
                
                var stressedUser = ""
                var timeStamp: Int64 = 0
                if let stressedUserInfo = groupDict["stressedUser"] as? NSDictionary {
                    stressedUser = stressedUserInfo["stressedUser"] as? String ?? ""
                    timeStamp = stressedUserInfo["timeStamp"] as? Int64 ?? 0
                }
                
                let groupData = Group(id: groupId, name: groupName, description: groupDescription, avatar: avatarName, stressedUser: stressedUser, timeStamp: timeStamp, users: idsArr)
                onCompletion(groupData)
            }
        }
    }
    
    // MARK: - Get Chat AudioMessages by Group Name
    func getChatAudioMessages(groupId: String, onCompletion: @escaping(_ chats: [AudioMessage]) -> Void) {
        self.databaseRef.child("groups").child(groupId).child("chats").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var chatMessages = [AudioMessage]()
            if let allChatsDict = snapshot.value as? NSDictionary {
                for (_, chatDict) in allChatsDict {
                    if let chatDetailsDict = chatDict as? NSDictionary {
                        let trackName = chatDetailsDict["track"] as? String
                        let artistName = chatDetailsDict["artist"] as? String
                        let time = chatDetailsDict["timeStamp"] as? String
                        let senderName = chatDetailsDict["sender"] as? String
                        let artworkUrl = chatDetailsDict["artworkUrl"] as? String
                        let previewUrl = chatDetailsDict["previewUrl"] as? String
                        
                        let message = AudioMessage(track: trackName, artist: artistName, previewUrl: previewUrl, artworkUrl: artworkUrl, sender: senderName, timeStamp: DatesHelper.shared.stringToDate(fromString: time ?? ""))
                        chatMessages.append(message)
                    }
                }
            }
            onCompletion(chatMessages)
        }
    }
    
    // MARK: - Update Device Tokens of all Users in the group
    func updateUsersDeviceTokenToGroup(groupId: String, tokens: [String]) {
        databaseRef.child("groups").child(groupId).updateChildValues(["tokens": tokens])
    }
    
    // MARK : - Send Audio Message
    func sendNewAudioMessage(groupId: String, audioMessage: Message, senderDeviceToken: String, onCompletion: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        let messageData: [String: Any] = ["artist": audioMessage.artist,
                                          "track": audioMessage.track,
                                          "previewUrl": audioMessage.previewUrl,
                                          "artworkUrl": audioMessage.artworkUrl,
                                          "sender": audioMessage.sender,
                                          "timeStamp": DatesHelper.shared.dateToString(fromDate: audioMessage.timeStamp),
                                          "senderDeviceToken": senderDeviceToken]
        
        databaseRef.child("groups").child(groupId).child("chats").childByAutoId().setValue(messageData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                onCompletion(false, error)
            } else {
                onCompletion(true, nil)
            }
        }
    }
    
    // MARK: - Get Group UserIds
    func getGroupIdsByName(groupName: String, onCompletion: @escaping(_ userIds: [String]?) -> Void) {
        guard let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" else {
            return
        }
        
        self.databaseRef.child("users").child(userId).child("groups").observeSingleEvent(of: .value) { (snapshot) in
            var userIds = [String]()
            if let requestsDict = snapshot.value as? NSDictionary {
                for (key, membersIds) in requestsDict {
                    if let name = key as? String,
                        let ids = membersIds as? [String: String],
                        name == groupName {
                        for (id, _) in ids {
                            userIds.append(id)
                        }
                    }
                }
            }
            onCompletion(userIds)
        }
    }
    
    // MARK: - Delete Group from Database
    func deleteGroupById(groupId: String, onCompletion: @escaping(_ success: Bool) -> Void) {
        let grpRef = databaseRef.child("groups").child(groupId)
        
        grpRef.removeValue { (error, _) in
            if let err = error, err.localizedDescription != "" {
                onCompletion(false)
            }
            
            onCompletion(true)
        }
    }
}
