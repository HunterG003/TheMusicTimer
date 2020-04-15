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
    
    // MARK: View DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
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
    
    fileprivate func setupView() {
        setupBackgroundImage()
        setupBlur()
    }
}
