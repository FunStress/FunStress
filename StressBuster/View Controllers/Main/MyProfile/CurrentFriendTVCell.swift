//
//  CurrentFriendTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/18/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class CurrentFriendTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var unfriendBtn: UIButton!
    
    var profile: Profile!
    var unfriendBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ profile: Profile) {
        self.profile = profile
        self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        self.unfriendBtn.setImageAndTitle()
    }
    
    @IBAction func unfriendBtnPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            self.unfriendBtnPressed?(true)
        } else {
            self.unfriendBtnPressed?(false)
        }
    }
}
