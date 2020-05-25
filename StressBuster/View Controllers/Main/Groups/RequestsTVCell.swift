//
//  RequestsTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/12/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class RequestsTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var confirmBtnPressed : ((_ selected: Bool) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func configureCell(_ userProfile: Profile) {
        if let contactName = ContactsHelper.shared.getContactName(contactNumber: userProfile.phoneNumber ?? "") {
            self.nameLbl.text = contactName
        } else {
            self.nameLbl.text = userProfile.phoneNumber ?? ""
        }
    }
    
    @IBAction func confirmBtnPressed(_ sender: UIButton) {
        if (confirmBtn.titleLabel?.text == "Confirm") {
            self.confirmBtnPressed?(true)
        } else {
            self.confirmBtnPressed?(false)
        }
    }
}
