//
//  AddMemberToGroupCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/24/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class AddMemberToGroupCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var addRemoveBtn: UIButton!
    
    var profile: Profile!
    var addRemoveBtnPressed : ((_ succcess: Bool, _ phoneNumber: String) -> Void)?
    
    func configureCell(_ profile: Profile) {
        self.profile = profile
        self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        self.phoneNumberLbl.text = profile.phoneNumber ?? ""
        
        self.profileImgView.setImage(string: profile.firstName, color: UIColor.colorHash(name: profile.firstName), circular: false, stroke: false, textAttributes: [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "Montserrat-Bold", size: 15.0), size: 15.0)])
    }
    
    @IBAction func addRemoveBtnPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if (sender.isSelected) {
            addRemoveBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            self.addRemoveBtnPressed?(true, profile.phoneNumber ?? "")
        } else {
            addRemoveBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            self.addRemoveBtnPressed?(false, profile.phoneNumber ?? "")
        }
    }
}
