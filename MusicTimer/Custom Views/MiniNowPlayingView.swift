//
//  MiniNowPlayingView.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/8/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit
import MediaPlayer

class MiniNowPlayingView: UIView {
    
    private let backgroundBlur : UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let label : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 25)
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private let playButton : UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "play.fill"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let forwardButton : UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "forward.fill"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let pauseImage = UIImage(systemName: "pause.fill")
    private let playImage = UIImage(systemName: "play.fill")
    
    init(image: UIImage, label: String) {
        self.imageView.image = image
        self.label.text = label
        super.init(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateChanged), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }
    
    let systemMusicController = MPMusicPlayerController.systemMusicPlayer
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        setupView()
    }
    
    private func setupView() {
        addSubview(backgroundBlur)
        addSubview(imageView)
        addSubview(label)
        addSubview(playButton)
        addSubview(forwardButton)
        
        let horizontalPadding : CGFloat = 20
        let verticalPadding : CGFloat = 5
        let itemSpacing : CGFloat = 10
        
        NSLayoutConstraint.activate([
            backgroundBlur.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBlur.topAnchor.constraint(equalTo: topAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: verticalPadding),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: itemSpacing),
            
            forwardButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            forwardButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1/1.4),
            forwardButton.heightAnchor.constraint(equalTo: imageView.heightAnchor),
            
            playButton.trailingAnchor.constraint(equalTo: forwardButton.leadingAnchor, constant: -itemSpacing * 2),
            playButton.centerYAnchor.constraint(equalTo: forwardButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalTo: forwardButton.widthAnchor),
            playButton.heightAnchor.constraint(equalTo: forwardButton.heightAnchor, multiplier: 1/1.4),
            
            label.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -itemSpacing)
        ])
        
        if systemMusicController.playbackState == .playing {
            playButton.image = pauseImage
        } else {
            playButton.image = playImage
        }
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playButton.addGestureRecognizer(playTap)
        
        let forwardTap = UITapGestureRecognizer(target: self, action: #selector(forwardButtonTapped))
        forwardButton.addGestureRecognizer(forwardTap)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(viewTapped))
        swipe.direction = .up
        imageView.addGestureRecognizer(viewTap)
        imageView.addGestureRecognizer(swipe)
        label.addGestureRecognizer(viewTap)
        label.addGestureRecognizer(swipe)
        addGestureRecognizer(viewTap)
        addGestureRecognizer(swipe)
        isUserInteractionEnabled = true
        
        if let item = systemMusicController.nowPlayingItem {
            imageView.image = item.artwork?.image(at: CGSize(width: 100, height: 100))
            label.text = "\(item.title ?? "")"
        }
    }
    
    @objc func playButtonTapped() {
        if systemMusicController.playbackState == .playing {
            systemMusicController.pause()
            playButton.image = playImage
        } else {
            systemMusicController.play()
            playButton.image = pauseImage
        }
    }
    
    @objc func forwardButtonTapped() {
        systemMusicController.skipToNextItem()
    }
    
    @objc func viewTapped() {
        NotificationCenter.default.post(.init(name: .init("MiniViewTapped")))
    }
    
    @objc func updateUI() {
        let item = systemMusicController.nowPlayingItem
        imageView.image = item?.artwork?.image(at: CGSize(width: 100, height: 100))
        label.text = "\(item?.title ?? "")"
    }
    
    @objc func playbackStateChanged() {
        if systemMusicController.playbackState == .playing {
            playButton.image = pauseImage
        } else {
            playButton.image = playImage
        }
    }
    
}
