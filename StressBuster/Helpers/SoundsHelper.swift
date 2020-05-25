//
//  SoundsHelper.swift
//  StressBuster
//
//  Created by Vamsikvkr on 2/2/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import Foundation
import AVFoundation

public final class SoundsHelper {
    
    // MARK: - Shared Instance
    static let shared = SoundsHelper()
    
    // MARK: - Stored Properties
    var songPlayer: AVAudioPlayer?
    
    // MARK: - Play Sound
    public func playSound(urlString: String) {
        let url = URL(string: urlString)!
        
        self.getData(from: url) { (mp3DataResponse, response, error) in
            do {
                if let mp3Data = mp3DataResponse {
                    self.songPlayer = try AVAudioPlayer(data: mp3Data, fileTypeHint: nil)
                    self.songPlayer?.play()
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                } catch let sessionErr {
                    print(sessionErr.localizedDescription)
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    public func pauseSound(urlString: String) {
        let url = URL(string: urlString)!
        
        self.getData(from: url) { (mp3DataResponse, response, error) in
            do {
                if let mp3Data = mp3DataResponse {
                    self.songPlayer = try AVAudioPlayer(data: mp3Data, fileTypeHint: nil)
                    self.songPlayer?.pause()
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                } catch let sessionErr {
                    print(sessionErr.localizedDescription)
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    public func stopSound(urlString: String) {
        let url = URL(string: urlString)!
        
        self.getData(from: url) { (mp3DataResponse, response, error) in
            do {
                if let mp3Data = mp3DataResponse {
                    self.songPlayer = try AVAudioPlayer(data: mp3Data, fileTypeHint: nil)
                    self.songPlayer?.stop()
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                } catch let sessionErr {
                    print(sessionErr.localizedDescription)
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func playSoundFromResources(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "caf") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            songPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = songPlayer else { return }
            player.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func stopSoundFromResources(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "caf") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            songPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = songPlayer else { return }
            player.stop()
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
