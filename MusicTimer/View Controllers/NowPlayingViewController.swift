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
        let blur = UIBlurEffect(style: .systemMaterial)
        view.effect = blur
        return view
    }()
    
    private let songImageView : RoundedImageWithShadow = {
        let view = RoundedImageWithShadow(cornerRadius: 20)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let backwardButton : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "backward")
        view.tintColor = .white
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let forwardButton : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "forward")
        view.tintColor = .white
        view.isUserInteractionEnabled = true
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
    
    var musicPlayer : MusicPlayer!
    private let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let playImage = UIImage(systemName: "play")
    private let pauseImage = UIImage(systemName: "pause")
    private var cachedImages = [UIImage]()
    private var lastSongImage : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupBackground()
        setupSongInfo()
        setupMediaControls()
        setupQueueView()
        updateLastSong()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayButton), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backwardButton.tintColor = .label
        playButton.tintColor = .label
        forwardButton.tintColor = .label
    }
    
    private func animateUIChange(backgroundImage: UIImage) {
        UIView.transition(with: self.backgroundImageView, duration: 1.0, options: .transitionCrossDissolve) {
            self.backgroundImageView.image = backgroundImage
        } completion: { (_) in
            
        }

    }
    
    @objc private func updateUI() {
        let currSong = systemMusicPlayer.nowPlayingItem
        let nextSong = systemMusicPlayer.indexOfNowPlayingItem != musicPlayer.musicQueue.count ? musicPlayer.musicQueue[systemMusicPlayer.indexOfNowPlayingItem + 1] : musicPlayer.musicQueue[0]
        
        // Update All Text Elements
        songTitleLabel.text = "\(currSong?.title ?? "")"
        songArtistLabel.text = "\(currSong?.artist ?? "")"
        songsRemainingLabel.text = "\(musicPlayer.musicQueue.count - systemMusicPlayer.indexOfNowPlayingItem) Songs Remaining"
        upNextView.songInfoLabel.text = "\(nextSong.name) - \(nextSong.artist)"

        
        // Download Images And Update UI
        let tempView = UIImageView()
        tempView.downloaded(from: musicPlayer.musicQueue[systemMusicPlayer.indexOfNowPlayingItem].artworkUrl!, contentMode: .scaleAspectFill) {
            DispatchQueue.main.async {
                self.songImageView.updateImage(with: tempView.image!)
                self.animateUIChange(backgroundImage: tempView.image!)
            }
        }
        
        upNextView.imageView.downloaded(from: nextSong.artworkUrl!, contentMode: .scaleAspectFit) {
            DispatchQueue.main.async {
                self.cachedImages.append(self.upNextView.imageView.image!)
            }
        }
    }
    
    // Separated this function because it only needs to be called once
    private func updateLastSong() {
        let lastSong = musicPlayer.musicQueue.last
        
        if lastSongImage != nil { return }
        
        lastSongView.songInfoLabel.text = "\(lastSong?.name ?? "") - \(lastSong?.artist ?? "")"
        lastSongView.imageView.downloaded(from: (lastSong?.artworkUrl!)!, contentMode: .scaleAspectFit) {
            DispatchQueue.main.async {
                self.lastSongImage = self.lastSongView.imageView.image!
            }
        }
    }
    
    @objc private func updatePlayButton() {
        if systemMusicPlayer.playbackState == .playing {
            playButton.image = pauseImage
        } else {
            playButton.image = playImage
        }
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
            songTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            songTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            
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
            volumeSlider.heightAnchor.constraint(equalTo: songImageView.heightAnchor, multiplier: 1/5)
        ])
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playButton.addGestureRecognizer(playTap)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backwardButtonTapped))
        backwardButton.addGestureRecognizer(backTap)
        
        let forwardTap = UITapGestureRecognizer(target: self, action: #selector(forwardButtonTapped))
        forwardButton.addGestureRecognizer(forwardTap)
        
        if systemMusicPlayer.playbackState == .playing {
            playButton.image = pauseImage
        } else {
            playButton.image = playImage
        }
        
        volumeSlider.tintColor = .label
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
        if systemMusicPlayer.playbackState == .playing {
            systemMusicPlayer.pause()
            playButton.image = playImage
        } else {
            systemMusicPlayer.play()
            playButton.image = pauseImage
        }
    }
    
    @objc func backwardButtonTapped() {
        systemMusicPlayer.skipToPreviousItem()
    }
    
    @objc func forwardButtonTapped() {
        systemMusicPlayer.skipToNextItem()
    }

}
