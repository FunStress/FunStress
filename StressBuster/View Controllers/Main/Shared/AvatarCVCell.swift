//
//  AvatarCVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class AvatarCVCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var avatarNameLbl: UILabel!
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                super.isSelected = true
                self.layer.cornerRadius = 10.0
                self.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 0.5)
            } else if newValue == false {
                super.isSelected = false
                self.layer.cornerRadius = 0.0
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    func configureAvatar(_ avatar: NSDictionary) {
        if let image = avatar["image"] as? String {
            self.avatarImgView.image = UIImage(named: image)
        }
        
        if let name = avatar["name"] as? String {
            self.avatarNameLbl.text = name
        }
    }
}
