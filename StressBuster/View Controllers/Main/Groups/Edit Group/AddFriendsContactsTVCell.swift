//
//  AddFriendsContactsTVCell.swift
//  StressBuster
//
//  Created by Vamsi Kamjula on 12/22/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class AddFriendsContactsTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    
    var profile: Profile!
    var addBtnPressed : ((_ succcess: Bool, _ phoneNumber: String) -> Void)?
    
    func configureCell(_ profile: Profile) {
        self.profile = profile
        self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        self.phoneNumberLbl.text = profile.phoneNumber ?? ""
        self.imgView.setImage(string: profile.firstName, color: UIColor.colorHash(name: profile.firstName), circular: false, stroke: false, textAttributes: [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "Montserrat-Bold", size: 15.0), size: 15.0)])
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if (sender.isSelected) {
            addBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            self.addBtnPressed?(true, profile.phoneNumber ?? "")
        } else {
            addBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            self.addBtnPressed?(false, profile.phoneNumber ?? "")
        }
    }
}
