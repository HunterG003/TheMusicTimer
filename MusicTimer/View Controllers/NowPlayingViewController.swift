//
//  NowPlayingViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/15/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController {

    // MARK: UI Variables
    private let backgroundImage : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "artwork")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let blurEffect : UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = UIBlurEffect(style: .prominent)
        return view
    }()
    
    private let songInfoView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let songInfoArtwork : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "artwork")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let songInfoArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Post Malone"
        return lbl
    }()
    
    private let songInfoTitleLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Stoney"
        return lbl
    }()
    
    // MARK: View DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: View Setup Functions
    
    fileprivate func setupBackgroundImage() {
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func setupBlur() {
        view.addSubview(blurEffect)
        NSLayoutConstraint.activate([
            blurEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffect.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func createSongInfoView() {
        let height = view.bounds.height / 2
        
        view.addSubview(songInfoView)
        NSLayoutConstraint.activate([
            songInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            songInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            songInfoView.topAnchor.constraint(equalTo: view.topAnchor),
            songInfoView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        songInfoView.addSubview(songInfoArtwork)
        songInfoView.addSubview(songInfoTitleLabel)
        songInfoView.addSubview(songInfoArtistLabel)
        NSLayoutConstraint.activate([
            songInfoArtwork.topAnchor.constraint(equalTo: songInfoView.topAnchor, constant: 10),
            songInfoArtwork.centerXAnchor.constraint(equalTo: songInfoView.centerXAnchor),
            songInfoArtwork.heightAnchor.constraint(equalToConstant: height / 1.5),
            
            songInfoTitleLabel.centerXAnchor.constraint(equalTo: songInfoView.centerXAnchor),
            songInfoTitleLabel.topAnchor.constraint(equalTo: songInfoArtwork.bottomAnchor, constant: 10),
            
            songInfoArtistLabel.centerXAnchor.constraint(equalTo: songInfoView.centerXAnchor),
            songInfoArtistLabel.topAnchor.constraint(equalTo: songInfoTitleLabel.bottomAnchor, constant: 10)
        ])
    }
    
    fileprivate func setupView() {
        setupBackgroundImage()
        setupBlur()
        createSongInfoView()
        
        
    }
}
