//
//  ContactsHelper.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/31/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import Foundation
import ContactsUI

public final class ContactsHelper {
    
    // MARK: - Shared Instance
    static let shared = ContactsHelper()
    
    func getContacts() -> [PhoneContact] {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch let err {
            print("Error: \(err), \(err.localizedDescription)")
            return []
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch let err {
                print("Error: \(err), \(err.localizedDescription)")
                return []
            }
        }
        return sortContacts(contacts: results)
    }
    
    fileprivate func sortContacts(contacts: [CNContact]) -> [PhoneContact] {
        var results: [PhoneContact] = []
        
        for contact in contacts {
            for contactNum: CNLabeledValue in contact.phoneNumbers {
                if let fullMobNum  = contactNum.value as? CNPhoneNumber {
                    if let mccName = fullMobNum.value(forKey: "digits") as? String {
                        if (contact.givenName != "") {
                            results.append(PhoneContact(firstName: contact.givenName, lastName: contact.familyName, phoneNumber: mccName, image: contact.thumbnailImageData))
                        }
                    }
                }
            }
        }
        
        return results.sorted { $0.firstName < $1.firstName }
    }
    
    func getContactName(contactNumber: String) -> String? {
        let contacts = self.getContacts()
        
        for contact in contacts {
            if (contact.phoneNumber == contactNumber) {
                return "\(contact.firstName) \(contact.lastName)"
            }
        }
        
        return nil
    }
}
