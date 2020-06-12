//
//  HelpVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 6/5/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit
import MessageUI

class HelpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var whatToDoLbl: UILabel!
    @IBOutlet weak var whatToExpectLbl: UILabel!
    @IBOutlet weak var allFeaturesIncludedLbl: UILabel!
    @IBOutlet weak var contactDetailsBtn: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var rateAppBtn: UIButton!
    
    // MARK: - Initialize MailComposeVC
    let mailComposerVC = MFMailComposeViewController()
    
    // MARK: - Stored Properties
    let whatToDoHTML = """
                            <ul><li>Inform your friends about 'Fun Stress' app and ask them to register.</li><li>Add friends by sending request from list of contacts in your phone book.</li><li>Once your friends accept your request, you are allowed to create a New Group.</li><li>Create new group with name, description, avatar and add friends.</li><li>Anyone can edit the group details at any time.</li></ul>
                            """
    let whatToExpectHTML = """
                                <ul><li>Once the group is created, you are allowed to send your favorite sample music tracks to all and also you can inform the group if you are feeling stressed.</li><li>Entire group is alerted about the stressed friend and allows others to send variety of music samples via the group.</li><li>Current stressed friend value is overridden if any other friend in the group is feeling stressed.</li><li>Stressed friend value will last upto 8 hours, after the group won't have any stressed friend unless someone alerts the group.</li></ul>
                            """
    let allFeatureIncludedHTML = """
                                        <ul><li>Selection of wide variety of avatars for your account and Group profile pictures.</li><li>Updating the group details and profiel information anytime except the phone number that is used at the registration time</li><li>Sample music track selection has a reach of 100 tracks, play and send any.</li></ul>
                                    """
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
    }
    
    fileprivate func configureUI() {
        self.whatToDoLbl.text = whatToDoHTML.htmlToString
        self.whatToExpectLbl.text = whatToExpectHTML.htmlToString
        self.allFeaturesIncludedLbl.text = allFeatureIncludedHTML.htmlToString
        
        // MARK: - Normal Text
        let mutableTitleString = NSMutableAttributedString()
        let normalText = NSAttributedString(string: "Send an Email at ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Poppins-Light", size: 14.0)!])
        
        let highlightedText = NSAttributedString(string: "stressapp123@gmail.com", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 0.75),  NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0)!])
        
        mutableTitleString.append(normalText)
        mutableTitleString.append(highlightedText)
        
        self.contactDetailsBtn.setAttributedTitle(mutableTitleString, for: .normal)
        
        if let bundleVerson = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLbl.text = "v \(bundleVerson)"
        }
        
        self.rateAppBtn.setImageAndTitle()
    }
    
    @IBAction func contactDetailsBtnPressed(_ sender: UIButton) {
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["stressapp123@gmail.com"])
        mailComposerVC.setSubject("FunStress Feedback")
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    @IBAction func rateAppBtnPressed(_ sender: UIButton) {
        self.rateApp()
    }
    
    fileprivate func rateApp() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") else {
            return
        }
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension HelpVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
