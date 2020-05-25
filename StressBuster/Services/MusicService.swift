//
//  MusicService.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/13/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public final class MusicService {
    
    // MARK: - Shared Instance
    static let shared = MusicService()
    
    // MARK: - Save User to Database
    func getMusicByArtistName(artistName: String, onCompletion: @escaping(_ music: [Music]?, _ error: Error?) -> Void) {
        let endPoint = "https://itunes.apple.com/search?term=\(artistName)&limit=100"
        
        if let baseUrl = URL(string: endPoint) {
            AF.request(baseUrl).responseJSON { (response) in
                guard let responseData = response.data else { return }
                var musicResults = [Music]()
                do {
                    let json = try JSON(data: responseData)
                    if let results = json["results"].array {
                        
                        for item in results {
                            let artistName = item["artistName"].stringValue
                            let trackName = item["trackName"].stringValue
                            let previewUrl = item["previewUrl"].stringValue
                            let artworkUrl = item["artworkUrl100"].stringValue
                            
                            let musicDetails = Music(artist: artistName, track: trackName, previewUrl: previewUrl, artworkUrl: artworkUrl)
                            musicResults.append(musicDetails)
                        }
                    }
                    onCompletion(musicResults, nil)
                } catch let err {
                    onCompletion(nil, err)
                    print(err.localizedDescription)
                }
            }
        }
    }
}
