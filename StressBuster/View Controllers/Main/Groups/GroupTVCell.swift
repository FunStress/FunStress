//
//  GroupTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/12/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class GroupTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    func configureCell(_ groupDetails: Group) {
        self.nameLbl.text = groupDetails.name ?? ""
        
        if let avatarName = groupDetails.avatar {
            let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
            let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
            let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
            self.avatarImgView.image = UIImage(named: hyphenReplaced)
        }
    }
}
