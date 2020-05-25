//
//  Models.swift
//  StressBuster
//
//  Created by Vamsikvkr on 3/12/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import Foundation

// MARK: - Emoji Model
struct Emoji {
    let image: String
    let expression: String
}

// MARK: - Country Code Model
struct Country {
    let name: String
    let dialCode: String
    let code: String
}

// MARK: - User Model
struct User {
    let deviceToken: String?
    let userId: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let avatar: String?
    let phoneNumber: String?
    let friendsIds: [String]?
    let requestIds: [String]?
}

// MARK: - Friend Profile Model
struct Profile {
    let id: String?
    let deviceToken: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let avatar: String?
    let phoneNumber: String?
}

// MARK:  - Contact Models
struct PhoneContact {
    let fullName: String
    let phoneNumber: String
}

// MARK: - Group Models
struct Group {
    let id: String?
    let name: String?
    let description: String?
    let avatar: String?
    let stressedUser: String?
    let timeStamp: Int64?
    let users: [String]?
}

struct AudioMessage {
    let track: String?
    let artist: String?
    let previewUrl: String?
    let artworkUrl: String?
    let sender: String?
    let timeStamp: Date?
}

// MARK: - GroupVC Model
struct Message {
    let track: String
    let artist: String
    let previewUrl: String
    let artworkUrl: String
    let sender: String
    let timeStamp: Date
}

// MARK: - Music Model
struct Music {
    let artist: String?
    let track: String?
    let previewUrl: String?
    let artworkUrl: String?
}
