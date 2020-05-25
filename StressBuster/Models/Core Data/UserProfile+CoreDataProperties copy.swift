//
//  UserProfile+CoreDataProperties.swift
//  
//
//  Created by Vamsikvkr on 4/18/20.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var avatar: String?
    @NSManaged public var deviceToken: String?
    @NSManaged public var firstName: String?
    @NSManaged public var friends: [String]?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var requests: [String]?

}
