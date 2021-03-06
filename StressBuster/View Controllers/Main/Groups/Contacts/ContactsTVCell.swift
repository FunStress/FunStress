//
//  ContactsTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class ContactsTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var contact: PhoneContact!
    
    func configureCell(_ contact: PhoneContact) {
        self.contact = contact
        if let imgData = contact.image {
            self.imgView.image = UIImage(data: imgData)
        } else {
            imgView.setImage(string: contact.firstName, color: UIColor.colorHash(name: contact.firstName), circular: false, stroke: false, textAttributes: [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "Montserrat-Bold", size: 15.0), size: 15.0)])
        }
        self.nameLbl.text = "\(contact.firstName) \(contact.lastName)"
        self.phoneNumberLbl.text = contact.phoneNumber
    }
}
