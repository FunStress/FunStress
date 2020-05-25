//
//  DeleteGroupAlertVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/14/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol DeleteGroupDelegate: class {
    func deleteGroup(_ success: Bool)
}

class DeleteGroupAlertVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var messageLbl: UILabel!
    
    // MARK: - Delegate
    weak var delegate: DeleteGroupDelegate?
    
    // MARK: - Stored Proerties
    var groupId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func yesBtnPressed(_ sender: UIButton) {
        FirebaseData.shared.deleteGroupById(groupId: self.groupId) { (success) in
            if (success) {
                self.delegate?.deleteGroup(true)
            } else {
                self.delegate?.deleteGroup(false)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func noBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
