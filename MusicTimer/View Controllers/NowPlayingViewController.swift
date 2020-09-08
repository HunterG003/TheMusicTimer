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
    private var upNextCachedImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupBackground()
        setupSongInfo()
        setupMediaControls()
        setupQueueView()
        updateUI()
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
    
    @objc private func updateUI() {
        
        if upNextCachedImage != nil {
            backgroundImageView.image = upNextCachedImage
            backgroundImageView.contentMode = .scaleAspectFill
            songImageView.image = upNextCachedImage
        } else {
            backgroundImageView.downloaded(from: musicPlayer.musicQueue[0].artworkUrl ?? "", contentMode: .scaleAspectFill, completion: {
                DispatchQueue.main.async {
                    self.songImageView.image = self.backgroundImageView.image
                }
            })
        }
        
        let currSong = systemMusicPlayer.nowPlayingItem
        songTitleLabel.text = currSong?.title
        songArtistLabel.text = currSong?.artist
        songsRemainingLabel.text = "\(musicPlayer.musicQueue.count - systemMusicPlayer.indexOfNowPlayingItem) Songs Remaining"
        
        if systemMusicPlayer.indexOfNowPlayingItem < musicPlayer.musicQueue.count - 1 {
            let index = systemMusicPlayer.indexOfNowPlayingItem + 1
            let nextSong = musicPlayer.musicQueue[index]
            upNextView.imageView.downloaded(from: nextSong.artworkUrl ?? "", completion: {
                DispatchQueue.main.async {
                    self.upNextCachedImage = self.upNextView.imageView.image
                }
            })
            upNextView.songInfoLabel.text = "\(nextSong.name) - \(nextSong.artist)"
        } else {
            songsRemainingLabel.text = "Last Song"
            let nextSong = musicPlayer.musicQueue[0]
            upNextView.imageView.downloaded(from: nextSong.artworkUrl ?? "", completion: {
                DispatchQueue.main.async {
                    self.upNextCachedImage = self.upNextView.imageView.image
                }
            })
            upNextView.songInfoLabel.text = "\(nextSong.name) - \(nextSong.artist)"
        }
        
        guard let lastSong = musicPlayer.musicQueue.last else { return }
        
        lastSongView.imageView.downloaded(from: lastSong.artworkUrl ?? "", completion: {})
        lastSongView.songInfoLabel.text = "\(lastSong.name) - \(lastSong.artist)"
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
            volumeSlider.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
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
