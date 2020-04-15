//
//  ViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: UI Variables
    private let playButton : UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        button.setTitle("Play", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setValue(UIFont.boldSystemFont(ofSize: 25), forKey: "Font")
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let nowPlayingCardView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let nowPlayingArtwork : UIImageView = {
        let i = UIImage(named: "artwork")
        let view = UIImageView(image: i)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let nowPlayingArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Post Malone"
        lbl.textColor = .black
        return lbl
    }()
    
    private let nowPlayingSongNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Stoney"
        lbl.textColor = .black
        return lbl
    }()
    
    private let timePicker : UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .countDownTimer
        picker.setValue(UIColor.black, forKey: "TextColor")
        return picker
    }()
    
    // MARK: VIEW DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
    }
    
    fileprivate func createNowPlayingCard() {
        view.addSubview(nowPlayingCardView)
        NSLayoutConstraint.activate([
            nowPlayingCardView.widthAnchor.constraint(equalToConstant: view.bounds.width / 1.3),
            nowPlayingCardView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            nowPlayingCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nowPlayingCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
        ])
        
        nowPlayingCardView.addSubview(nowPlayingArtwork)
        nowPlayingCardView.addSubview(nowPlayingSongNameLabel)
        nowPlayingCardView.addSubview(nowPlayingArtistLabel)
        NSLayoutConstraint.activate([
            nowPlayingArtwork.centerXAnchor.constraint(equalTo: nowPlayingCardView.centerXAnchor),
            nowPlayingArtwork.topAnchor.constraint(equalTo: nowPlayingCardView.topAnchor, constant: 5),
            nowPlayingArtwork.heightAnchor.constraint(equalToConstant: view.bounds.height / 4),
            
            nowPlayingSongNameLabel.centerXAnchor.constraint(equalTo: nowPlayingCardView.centerXAnchor),
            nowPlayingSongNameLabel.topAnchor.constraint(equalTo: nowPlayingArtwork.bottomAnchor, constant: 5),
            // Add a width later for the labels
            nowPlayingArtistLabel.centerXAnchor.constraint(equalTo: nowPlayingCardView.centerXAnchor),
            nowPlayingArtistLabel.topAnchor.constraint(equalTo: nowPlayingSongNameLabel.bottomAnchor, constant: 5)
        ])
    }
    
    fileprivate func createTimePicker() {
        view.addSubview(timePicker)
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: nowPlayingCardView.bottomAnchor, constant: 20)
        ])
    }
    
    func setupView() {
        createNowPlayingCard()
        createTimePicker()
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 40),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func playButtonPressed(_ button : UIButton) {
        print("Play Button Pressed")
        present(NowPlayingViewController(), animated: true)
    }


}

