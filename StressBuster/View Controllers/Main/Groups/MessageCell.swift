//
//  MessageCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/21/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var trackLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet var playImgView: UIImageView!
    @IBOutlet weak var senderLbl: UILabel!
    
    func configureCell(_ messageDetails: Message) {
        self.trackLbl.text = messageDetails.track
        self.artistLbl.text = messageDetails.artist
        self.senderLbl.text = messageDetails.sender
        
        if let imageUrl = URL(string: messageDetails.artworkUrl) {
            self.albumImgView.load(url: imageUrl)
        }
    }
}
