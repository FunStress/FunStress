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
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var addRemoveBtn: UIButton!
    
    var profile: Profile!
    var addRemoveBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ profile: Profile) {
        self.profile = profile
        self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        
        if let avatarName = profile.avatar {
            let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
            let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
            let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
            self.profileImgView.image = UIImage(named: hyphenReplaced)
        }
    }
    
    @IBAction func addRemoveBtnPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            addRemoveBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            self.addRemoveBtnPressed?(true)
        } else {
            addRemoveBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            self.addRemoveBtnPressed?(false)
        }
    }
}
