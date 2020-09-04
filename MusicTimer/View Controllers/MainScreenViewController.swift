//
//  MainScreenViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    private let playlistView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let playlistImage : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "artwork")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let playlistHeadingLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Playlist"
        lbl.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        return lbl
    }()
    
    private let playlistNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Straight Vibes"
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return lbl
    }()
    
    private let timePicker : UIDatePicker = {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.datePickerMode = .countDownTimer
        return view
    }()
    
    private let playButton : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemBlue
        btn.setTitle("Play", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var musicPlayer = MusicPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        setupPlaylistView()
        setupTimePicker()
        setupPlayButton()
        setupMusicPlayer()
    }
    
    func updatePlaylist(name: String, image: String) {
        playlistImage.downloaded(from: image)
        playlistNameLabel.text = name
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        playlistView.layer.borderColor = UIColor.label.cgColor
        playlistView.layer.shadowColor = UIColor.label.cgColor
    }
    
    private func setupPlaylistView() {
        view.addSubview(playlistView)
        playlistView.addSubview(playlistImage)
        playlistView.addSubview(playlistHeadingLabel)
        playlistView.addSubview(playlistNameLabel)
        
        NSLayoutConstraint.activate([
            playlistView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playlistView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playlistView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height / 8),
            playlistView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10),
            
            playlistImage.topAnchor.constraint(equalTo: playlistView.topAnchor),
            playlistImage.leadingAnchor.constraint(equalTo: playlistView.leadingAnchor),
            playlistImage.bottomAnchor.constraint(equalTo: playlistView.bottomAnchor),
            playlistImage.widthAnchor.constraint(equalTo: playlistImage.heightAnchor),
            
            playlistHeadingLabel.leadingAnchor.constraint(equalTo: playlistImage.trailingAnchor, constant: 10),
            playlistHeadingLabel.bottomAnchor.constraint(equalTo: playlistView.centerYAnchor, constant: -1),
            
            playlistNameLabel.leadingAnchor.constraint(equalTo: playlistHeadingLabel.leadingAnchor),
            playlistNameLabel.topAnchor.constraint(equalTo: playlistView.centerYAnchor),
            playlistNameLabel.trailingAnchor.constraint(equalTo: playlistView.trailingAnchor),
            playlistNameLabel.bottomAnchor.constraint(equalTo: playlistView.bottomAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(playlistViewTapped))
        playlistView.addGestureRecognizer(tap)
    }
    
    private func setupTimePicker() {
        view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: playlistView.bottomAnchor, constant: view.bounds.height / 8),
            timePicker.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4)
        ])
    }
    
    private func setupPlayButton() {
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: view.bounds.height / 8),
            playButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor, multiplier: 1/2)
        ])
        
        playButton.layer.cornerRadius = view.bounds.width / 12
    }
    
    private func setupMusicPlayer() {
        musicPlayer.getAuth()
    }
    
    @objc func playlistViewTapped() {
        let vc = PlaylistSelectionViewController()
        vc.musicPlayer = self.musicPlayer
        vc.previousVC = self
        present(vc, animated: true)
    }
    
    @objc func playButtonTapped(_ button : UIButton) {
        present(NowPlayingViewController(), animated: true)
    }

}
