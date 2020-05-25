//
//  DatesHelper.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/20/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation

public final class DatesHelper {
    
    // MARK: - Shared Instance
    static let shared = DatesHelper()
    
    // MARK: - Sending date to server
    public func dateToString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Reading the date from the server
    public func stringToDate(fromString string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        return dateFormatter.date(from: string)!
    }
    
    // MARK: - Readable date format
    public func dateToReadableString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter.string(from: date)
    }
}
