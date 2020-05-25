//
//  UIImageView+Extensions.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/30/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
