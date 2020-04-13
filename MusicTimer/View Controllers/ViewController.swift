//
//  ViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let COLORS = [UIColor.red, UIColor.blue, UIColor.green, UIColor.gray, UIColor.black, UIColor.white]
    let musicPlayer = MusicPlayer()
    
    // MARK: UI Variables
    private let playButton : UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        button.setTitle("Play", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: VIEW DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = COLORS.randomElement()
        setupView()
        musicPlayer.getUserToken()
        musicPlayer.getStoreFront()
    }
    
    func setupView() {
        buildButtons()
    }
    
    func buildButtons() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func playButtonPressed(_ button : UIButton) {
        view.backgroundColor = COLORS.randomElement()
        
        musicPlayer.getUsersPlaylists()
    }


}

