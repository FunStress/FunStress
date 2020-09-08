//
//  AgreementsTVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 8/22/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

let AGREEMENTS_WEBVIEW_SEGUE = "toAgreementsWebViewSegue"
let PRIVACY_POLICY_CELL_TAG = 10
let EULA_CELL_TAG = 11

class AgreementsTVC: UITableViewController {

    var agreementText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Secutiy & Policy"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == AGREEMENTS_WEBVIEW_SEGUE) {
            if let privacyPolicyVC = segue.destination as? PrivacyPolicyVC {
                privacyPolicyVC.webViewText = agreementText
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if (cell.tag == PRIVACY_POLICY_CELL_TAG) {
                agreementText = privacyPolicy
            } else if (cell.tag == EULA_CELL_TAG) {
                agreementText = eula
            } else {
                debugPrint("No row is selected")
            }
            performSegue(withIdentifier: AGREEMENTS_WEBVIEW_SEGUE, sender: nil)
        }
    }
}
