//
//  MusicTVCell.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/13/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class MusicTVCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var trackLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var playImgView: UIImageView!
    
    func configureCell(_ musicDetails: Music) {
        self.trackLbl.text = musicDetails.track
        self.artistLbl.text = musicDetails.artist
        
        if let urlString = musicDetails.artworkUrl, let imageUrl = URL(string: urlString) {
            self.albumImgView.load(url: imageUrl)
        }
    }
}
