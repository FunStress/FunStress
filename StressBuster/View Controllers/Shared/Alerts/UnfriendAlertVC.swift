//
//  UnfriendAlertVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 2/15/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol UnfriendDelegate: class {
    func unfriendUser(_ success: Bool)
}

class UnfriendAlertVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var messageLbl: UILabel!
    
    // MARK: - Delegate
    weak var delegate: UnfriendDelegate?
    
    // MARK: - Stored Properties
    var successMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSuccessMessage(message: self.successMessage)
    }
    
    func setUpSuccessMessage(message: String) {
        self.messageLbl.text = message
    }
    
    @IBAction func noBtnPressed(_ sender: UIButton) {
        self.delegate?.unfriendUser(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesBtnPressed(_ sender: UIButton) {
        self.delegate?.unfriendUser(true)
        self.dismiss(animated: true, completion: nil)
    }
}
