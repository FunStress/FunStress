//
//  ChatTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/12/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class ChatTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var alertBtn: UIButton!
    
    var confirmBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ groupDetails: Group) {
        if (groupDetails.isGroup == true) {
            self.nameLbl.text = groupDetails.name ?? ""
        } else {
            FirebaseData.shared.retrieveCurrentUserUID { (uid) in
                if (uid != "") {
                    if let filteredUsers = groupDetails.users?.filter({ !$0.contains(uid) }) {
                        FirebaseData.shared.retrieveDataWith(userId: filteredUsers[0]) { (profile) in
                            self.nameLbl.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
                        }
                    }
                }
            }
        }
        
        
        if let avatarName = groupDetails.avatar {
            let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
            let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
            let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
            self.avatarImgView.image = UIImage(named: hyphenReplaced)
        }
    }
    
    @IBAction func alertBtnPressed(_ sender: Any) {
        self.confirmBtnPressed?(true)
    }
}
