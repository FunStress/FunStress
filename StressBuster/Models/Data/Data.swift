//
//  Data.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/20/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation

struct Status {
    let status: Bool
    let senderId: String?
    let receiverId: String?
    let timeStamp: String?
}

struct Sound {
    let receiverId: String?
    let senderId: String?
    let soundName: String?
}
