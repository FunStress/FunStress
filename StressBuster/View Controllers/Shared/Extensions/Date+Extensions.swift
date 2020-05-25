//
//  Date+Extensions.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/15/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
