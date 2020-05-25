//
//  ErrorAlertVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 12/17/19.
//  Copyright © 2019 StressBuster. All rights reserved.
//

import UIKit

class ErrorAlertVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var messageLbl: UILabel!
    
    var errorMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpErrorMessage(message: self.errorMessage)
    }
    
    func setUpErrorMessage(message: String) {
        self.messageLbl.text = message
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
