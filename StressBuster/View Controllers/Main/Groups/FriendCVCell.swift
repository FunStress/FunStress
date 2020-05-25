//
//  FriendCVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/12/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class FriendCVCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var avatarImgView: UIImageView!
    
    var addBtnPressed : ((_ selected: Bool) -> Void)?
    
    func configureCell(_ userProfile: Profile) {
        self.nameLbl.text = "\(String(describing: userProfile.firstName ?? "")) \(String(describing: userProfile.lastName ?? ""))"
        
        if let avatarName = userProfile.avatar {
            let spaceReplaced = avatarName.replacingOccurrences(of: " ", with: "")
            let dotReplaced = spaceReplaced.replacingOccurrences(of: ".", with: "")
            let hyphenReplaced = dotReplaced.replacingOccurrences(of: "-", with: "")
            self.avatarImgView.image = UIImage(named: hyphenReplaced)
        }
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        if (addBtn.imageView?.image == UIImage(named: "plusCircle")) {
            addBtn.setImage(UIImage(named: "minusCircle"), for: .normal)
            self.addBtnPressed?(true)
        } else {
            addBtn.setImage(UIImage(named: "plusCircle"), for: .normal)
            self.addBtnPressed?(false)
        }
    }
}
