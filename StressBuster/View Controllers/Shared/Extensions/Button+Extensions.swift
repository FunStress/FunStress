//
//  Button+Extensions.swift
//  StressBuster
//
//  Created by Vamsikvkr on 6/10/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

extension UIButton {
    func setImageAndTitle() {
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (imageView?.frame.width)!, bottom: 0, right: 5)
        } 
    }
}
