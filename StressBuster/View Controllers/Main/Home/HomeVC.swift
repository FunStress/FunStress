//
//  HomeVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/23/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit
import MessageUI

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var whatToDoLbl: UILabel!
    @IBOutlet weak var whatToExpectLbl: UILabel!
    @IBOutlet weak var allFeaturesIncludedLbl: UILabel!
    @IBOutlet weak var contactDetailsBtn: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var homeAnimationView: UIView!
    
    // MARK: - Constraint Outlets
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
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
    
    var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerHeightConstraint.constant = UIScreen.main.bounds.size.height - 175.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
        self.makeBubbles()
    }
    
    
    
    fileprivate func makeBubbles() {
        let emitter = Emitter.get(with: #imageLiteral(resourceName: "bubbleShadow"))
        emitter.emitterPosition = CGPoint(x: homeAnimationView.frame.width / 2, y: homeAnimationView.frame.height)
        emitter.emitterSize = CGSize(width: homeAnimationView.frame.width * 0.75, height: 2)
        homeAnimationView.layer.addSublayer(emitter)
        
        let emojiImage = UIImage(named: "emoji_1")
        let emojiImageView:UIImageView = UIImageView()
        emojiImageView.contentMode = UIView.ContentMode.scaleAspectFit
        emojiImageView.frame.size.width = 150
        emojiImageView.frame.size.height = 150
        emojiImageView.center.x = self.homeAnimationView.center.x - 15.0
        emojiImageView.center.y = self.homeAnimationView.center.y - 40.0
        emojiImageView.image = emojiImage
        
        self.homeAnimationView.addSubview(emojiImageView)
        
        emojiImageView.animationImages = [#imageLiteral(resourceName: "emoji_1"), #imageLiteral(resourceName: "emoji_2"), #imageLiteral(resourceName: "emoji_3"), #imageLiteral(resourceName: "emoji_4"), #imageLiteral(resourceName: "emoji_5")]
        emojiImageView.animationDuration = 1.5
        emojiImageView.startAnimating()
        
        playBtn = UIButton(frame: CGRect(x: homeAnimationView.frame.width / 2, y: homeAnimationView.frame.height - 75, width: 75, height: 75))
        playBtn.center.x = self.homeAnimationView.center.x - 20.0
        playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
        playBtn.addTarget(self, action: #selector(playBtnPressed), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: { () -> Void in
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.homeAnimationView.addSubview(self.playBtn)
            })
        })
    }
    
    @objc func playBtnPressed(sender: UIButton!) {
        if (sender.imageView?.image == UIImage(named: "playHomeBtn")) {
            SoundsHelper.shared.playSoundFromResources(soundName: "frustration")
            self.playBtn.setImage(UIImage(named: "pauseHomeBtn"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(37), execute: { () -> Void in
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
                })
            })
        } else {
            SoundsHelper.shared.stopSoundFromResources(soundName: "frustration")
            self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(37), execute: { () -> Void in
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
                })
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SoundsHelper.shared.stopSoundFromResources(soundName: "frustration")
    }
    
    fileprivate func configureUI() {
        if let user = CDManager.shared.retrieveUserData(), let userId = user.userId, userId != "" {
            self.navigationItem.title = "Welcome back Mr. \(user.lastName ?? "") !"
        } else {
            self.navigationItem.title = "FunStress"
        }
        
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.black,
         NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17.0)!]
        
        self.whatToDoLbl.text = whatToDoHTML.htmlToString
        self.whatToExpectLbl.text = whatToExpectHTML.htmlToString
        self.allFeaturesIncludedLbl.text = allFeatureIncludedHTML.htmlToString
        
        // MARK: - Normal Text
        let mutableTitleString = NSMutableAttributedString()
        let normalText = NSAttributedString(string: "Send an Email at ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Poppins-Light", size: 10.0)!])
        
        let highlightedText = NSAttributedString(string: "stressapp123@gmail.com", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 0.75),  NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 10.0)!])
        
        mutableTitleString.append(normalText)
        mutableTitleString.append(highlightedText)
        
        self.contactDetailsBtn.setAttributedTitle(mutableTitleString, for: .normal)
        
        if let bundleVerson = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLbl.text = "v \(bundleVerson)"
        }
    }
    
    @IBAction func playSoundBtnPressed(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
        },
                       completion: nil)
        
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            sender.setTitle("Pause.", for: UIControl.State.normal)
            SoundsHelper.shared.playSoundFromResources(soundName: "frustration")
        } else {
            sender.setTitle("Play!", for: UIControl.State.normal)
            SoundsHelper.shared.stopSoundFromResources(soundName: "frustration")
        }
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

extension HomeVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
