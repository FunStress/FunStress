//
//  SearchMusicVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 4/11/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

protocol SendMusicDelegate: class {
    func selected(music: Music)
}

class SearchMusicVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    // MARK: - Delegate
    weak var delegate: SendMusicDelegate?
    
    // MARK: - Stored Properties
    var selectedMusic: Music!
    var allMusicTracks = [Music]()
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.selectedMusic != nil) {
            SoundsHelper.shared.stopSound(urlString: self.selectedMusic.previewUrl ?? "")
        }
    }
    
    fileprivate func configureUI() {
        // SearchBar
        searchBar.showsCancelButton = false
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = UIFont(name: "Poppins-Regular", size: 17.0)

        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.lightGray
        
        self.reloadData()
        self.sendBtn.setImageAndTitle()
    }
    
    fileprivate func reloadData() {
        if (self.allMusicTracks.count > 0) {
            self.tableView.isHidden = false
            self.warningLbl.isHidden = true
        } else if (self.allMusicTracks.count == 0 && searchBar.text != "") {
            self.tableView.isHidden = true
            self.warningLbl.isHidden = false
            self.warningLbl.text = "Something went wrong, please try again after sometime."
        } else {
            self.tableView.isHidden = true
            self.warningLbl.isHidden = false
            self.warningLbl.text = "Start searching for music!"
        }

        self.tableView.reloadData()
        self.activityIndicator.isHidden = true
    }
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        if (self.selectedMusic == nil) {
            self.presentErrorAlert(errorMessage: "Please select a music to send!")
            return
        }
        SoundsHelper.shared.stopSound(urlString: selectedMusic.previewUrl ?? "")
        self.delegate?.selected(music: self.selectedMusic)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        if (self.selectedMusic != nil) {
            SoundsHelper.shared.stopSound(urlString: selectedMusic.previewUrl ?? "")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchMusicVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMusicTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath) as? MusicTVCell {
            
            let music = self.allMusicTracks[indexPath.row]
            cell.configureCell(music)
            
            
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        if let cell = tableView.cellForRow(at: indexPath) as? MusicTVCell {
            let music = self.allMusicTracks[indexPath.row]
            
            if (cell.playImgView.image == UIImage(named: "playIcon")) {
                self.selectedMusic = music
                cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                cell.playImgView.image = UIImage(named: "pauseIcon")
                SoundsHelper.shared.playSound(urlString: music.previewUrl ?? "")
            } else {
                self.selectedMusic = nil
                cell.backgroundColor = UIColor.white
                cell.playImgView.image = UIImage(named: "playIcon")
                SoundsHelper.shared.stopSound(urlString: music.previewUrl ?? "")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MusicTVCell {
            let music = self.allMusicTracks[indexPath.row]
            
            cell.backgroundColor = UIColor.white
            cell.playImgView.image = UIImage(named: "playIcon")
            SoundsHelper.shared.stopSound(urlString: music.previewUrl ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension SearchMusicVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, searchText != "" {
            searchBar.showsCancelButton = true
            let spaceReplaced = searchText.replacingOccurrences(of: " ", with: "+")
            MusicService.shared.getMusicByArtistName(artistName: spaceReplaced) { (music, error) in
                if (error != nil) {
                    self.presentErrorAlert(errorMessage: "Something went wrong, please try again after sometime.")
                }
                
                if let musicTracks = music {
                    self.allMusicTracks = musicTracks
                }

                self.reloadData()
            }
        } else {
            searchBar.showsCancelButton = false
            self.reloadData()
        }
        
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tableView.reloadData()
        searchBar.endEditing(true)
    }
}
