//
//  NowPlayingViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/3/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit
import MediaPlayer

class NowPlayingViewController: UIViewController {
    
    private let backgroundImageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "artwork")
        return view
    }()
    
    private let blurEffectView : UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let blur = UIBlurEffect(style: .prominent)
        view.effect = blur
        return view
    }()
    
    private let songImageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "artwork")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let songTitleLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Stoney"
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let songArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Post Malone"
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let playButton : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "play")
        view.tintColor = .white
        return view
    }()
    
    private let backwardButton : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "backward")
        view.tintColor = .white
        return view
    }()
    
    private let forwardButton : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "forward")
        view.tintColor = .white
        return view
    }()
    
    private let volumeSlider : MPVolumeView = {
        let view = MPVolumeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let songsRemainingLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "15 Songs Remaining"
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 25)
        return lbl
    }()
    
    private let upNextView : SongPreviewView = {
        let view = SongPreviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lastSongView : SongPreviewView = {
        let view = SongPreviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.headingLabel.text = "Last Song"
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupBackground()
        setupSongInfo()
        setupMediaControls()
        setupQueueView()
    }
    
    private func setupBackground() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor)
        ])
    }
    
    private func setupSongInfo() {
        view.addSubview(songImageView)
        view.addSubview(songTitleLabel)
        view.addSubview(songArtistLabel)
        
        let songHeightMultiplier : CGFloat = 1/1.8
        
        NSLayoutConstraint.activate([
            songImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            songImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: songHeightMultiplier),
            songImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: songHeightMultiplier),
            
            songTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songTitleLabel.topAnchor.constraint(equalTo: songImageView.bottomAnchor, constant: 10),
            
            songArtistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songArtistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 5)
        ])
    }
    
    private func setupMediaControls() {
        view.addSubview(playButton)
        view.addSubview(backwardButton)
        view.addSubview(forwardButton)
        view.addSubview(volumeSlider)
        
        let multiplier : CGFloat = 1/4
        let padding = view.bounds.width * (multiplier / 4)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            playButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            playButton.topAnchor.constraint(equalTo: songArtistLabel.bottomAnchor, constant: 25),
            
            backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -padding),
            backwardButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            backwardButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            backwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            
            forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: padding),
            forwardButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            forwardButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            
            volumeSlider.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 10),
            volumeSlider.leadingAnchor.constraint(equalTo: backwardButton.leadingAnchor),
            volumeSlider.trailingAnchor.constraint(equalTo: forwardButton.trailingAnchor),
            volumeSlider.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
        ])
    }
    
    private func setupQueueView() {
        view.addSubview(songsRemainingLabel)
        view.addSubview(upNextView)
        view.addSubview(lastSongView)
        
        NSLayoutConstraint.activate([
            songsRemainingLabel.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor),
            songsRemainingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            upNextView.leadingAnchor.constraint(equalTo: backwardButton.leadingAnchor),
            upNextView.trailingAnchor.constraint(equalTo: forwardButton.trailingAnchor),
            upNextView.topAnchor.constraint(equalTo: songsRemainingLabel.bottomAnchor, constant: 10),
            upNextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/15),
            
            lastSongView.leadingAnchor.constraint(equalTo: upNextView.leadingAnchor),
            lastSongView.trailingAnchor.constraint(equalTo: upNextView.trailingAnchor),
            lastSongView.topAnchor.constraint(equalTo: upNextView.bottomAnchor, constant: 30),
            lastSongView.heightAnchor.constraint(equalTo: upNextView.heightAnchor)
        ])
    }
    
    @objc func playButtonTapped() {
        print("play")
    }
    
    @objc func backwardButtonTapped() {
        print("backward")
    }
    
    @objc func forwardButtonTapped() {
        print("forward")
    }

}
