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
    @IBOutlet weak var addBtn: UIButton!
    
    var contact: PhoneContact!
    var addBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ contact: PhoneContact) {
        self.contact = contact
        self.nameLbl.text = contact.fullName
        self.phoneNumberLbl.text = contact.phoneNumber
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        if (addBtn.titleLabel?.text == "Add") {
            self.addBtnPressed?(true)
        } else {
            self.addBtnPressed?(false)
        }
    }
}
