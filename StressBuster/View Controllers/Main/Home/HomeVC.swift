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
    @IBOutlet weak var homeAnimationView: UIView!
    @IBOutlet weak var mainEmojiImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleImgView: UIImageView!
    @IBOutlet weak var emojiImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emojiBtnTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        emojiImgView.addGestureRecognizer(emojiBtnTapGesture)
        
        mainEmojiImgView.isHidden = true
        titleImgView.isHidden = true
        titleLbl.isHidden = true
        
        self.makeBubbles()
    }
    
    fileprivate func makeBubbles() {
        let emitter = Emitter.get(with: #imageLiteral(resourceName: "bubbleShadow"))
        emitter.emitterPosition = CGPoint(x: homeAnimationView.frame.width / 2, y: homeAnimationView.frame.height)
        emitter.emitterSize = CGSize(width: homeAnimationView.frame.width * 0.75, height: 2)
        homeAnimationView.layer.addSublayer(emitter)
        
        mainEmojiImgView.isHidden = false
        titleLbl.isHidden = false
        titleImgView.isHidden = false
        
        emojiImgView.animationImages = [#imageLiteral(resourceName: "emoji_1"), #imageLiteral(resourceName: "emoji_2"), #imageLiteral(resourceName: "emoji_3"), #imageLiteral(resourceName: "emoji_4"), #imageLiteral(resourceName: "emoji_5")]
        emojiImgView.animationDuration = 1.5
        emojiImgView.startAnimating()
    }
    
    @objc func handleTapGesture() {
        SoundsHelper.shared.playSoundFromResources(soundName: "frustration")
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "playHomeBtn")) {
            SoundsHelper.shared.playSoundFromResources(soundName: "frustration")
//            self.playBtn.setImage(UIImage(named: "pauseHomeBtn"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(37), execute: { () -> Void in
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
//                    self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
                })
            })
        } else {
            SoundsHelper.shared.stopSoundFromResources(soundName: "frustration")
//            self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(37), execute: { () -> Void in
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
//                    self.playBtn.setImage(UIImage(named: "playHomeBtn"), for: .normal)
                })
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SoundsHelper.shared.stopSoundFromResources(soundName: "frustration")
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
}
