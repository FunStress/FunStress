//
//  AddFriendsTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/18/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class AddFriendsTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    var profile: Profile!
    var addBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ profile: Profile) {
        self.profile = profile
        self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "plusCircle")) {
            self.addBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            self.addBtnPressed?(true)
        } else {
            self.addBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            self.addBtnPressed?(false)
        }
    }
}
