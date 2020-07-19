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
    @IBOutlet weak var introLbl: UILabel!
    @IBOutlet weak var whatToDoLbl: UILabel!
    @IBOutlet weak var allFeaturesIncludedLbl: UILabel!
    @IBOutlet weak var otherFeaturesIncludedLbl: UILabel!
    @IBOutlet weak var contactDetailsBtn: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var rateAppBtn: UIButton!
    
    // MARK: - Initialize MailComposeVC
    let mailComposerVC = MFMailComposeViewController()
    
    // MARK: - Stored Properties
    let intrductionHTML = """
                            Coronavirus has been shaking the world. We know that it may be a stressful time for everyone. In order to release people’s stress, we created Tusic! Tusic is a fun, interactive way to text your friends different snip-it’s of music from any language in the world whenever they feel stressed and vice versa.  In addition, you could also “text” your friends with music just for fun./n This app has alert system when you stressed to a group or individuals
                          """
    let whatToDoHTML = """
                        <ul><li>Download the app by searching up “Tusic” on the App Store</li><li>Inform your friends about the “Tusic” app and ask them to download and make an account</li><li>Add your fellow friends that downloaded the app by sending them a request from the list of contacts from your phone book</li><li>After your friends accept the request, form a group together</li>Create a name, description, and an avatar for your group. Choose from a wide variety of avatars!</li><li>Anyone part of the group can edit the group details any time.</li><li>Start texting some music!!</li></ul>
                        """
    let allFeatureIncludedHTML = """
                                    <ul><li>In the Home page, there’s a smiley face button that says “Press Me” that will play a funny tune to alleviate your stress</li><li>There’s a “I’m Stressed” button that allows you to send a notification to your friends whenever you feel stressed</li><li>You will be notified if your friend is stressed with a catchy notification tune or vice versa</li><li>You can chat with music with a group of friends by sending different kinds of music with one another, whether your stressed or not stressed, by clicking on the “Send Music” button</li><li>Current friend that is stressed is overridden if another friend from the same group becomes stressed. The stressed friend value with only last up to 8 hrs. After that, there won’t be any stressed friends unless someone alerts the group</li></ul>
                                    """
    let otherFeatureIncludedHTML = """
                                    <ul><li>You are able to send a wide variety of music tracks from around the world to all your group members for fun</li><li>Sample music track selection has a reach of 100 tracks</li><li>You can either upload any of the provided avatars for your account profile or group</li><ul>
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
        self.allFeaturesIncludedLbl.text = allFeatureIncludedHTML.htmlToString
        self.otherFeaturesIncludedLbl.text = otherFeatureIncludedHTML.htmlToString
        
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
