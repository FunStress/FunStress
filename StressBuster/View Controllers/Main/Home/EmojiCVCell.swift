//
//  EmojiCVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/29/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class EmojiCVCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var emojiImgView: UIImageView!
    @IBOutlet weak var expressionNameLbl: UILabel!
    
    func configureUI(_ emoji: Emoji) {
        self.emojiImgView.image = UIImage(named: emoji.image)
        self.expressionNameLbl.text = emoji.expression
    }
}
