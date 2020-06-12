//
//  AlertGroupVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol AlertGroupDelegate: class {
    func alertGroup(success: Bool)
}

class AlertGroupVC: UIViewController {
    
    @IBOutlet weak var alertGrpBtn: UIButton!
    
    // MARK: - Delegate
    weak var delegate: AlertGroupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.alertGrpBtn.setImageAndTitle()
    }
    
    @IBAction func alertGrpBtnPressed(_ sender: UIButton) {
        self.delegate?.alertGroup(success: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.delegate?.alertGroup(success: false)
        self.dismiss(animated: true, completion: nil)
    }
}
