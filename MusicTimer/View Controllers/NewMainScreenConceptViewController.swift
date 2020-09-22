//
//  NewMainScreenConceptViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/22/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class NewMainScreenConceptViewController: UIViewController {
    
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    
    private let backgroundImage : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "artwork")
        return view
    }()
    
    private let blurView : UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 30
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(NewPlaylistCell.self, forCellWithReuseIdentifier: "NewPlaylistCell")
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let playlistNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Straight Vibes"
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        lbl.textColor = .white
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
        btn.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        btn.backgroundColor = .systemBlue
        btn.setTitle("PLAY", for: .normal)
        btn.titleLabel!.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return btn
    }()
    
    private let miniPlayer : MiniNowPlayingView = {
        let view = MiniNowPlayingView(image: UIImage(named: "artwork")!, label: "Circles - Post Malone")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupCollectionView()
        setupTimePicker()
        setupPlayButton()
        setupMiniPlayer()
    }
    
    private func setupBackground() {
        view.addSubview(backgroundImage)
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(playlistNameLabel)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            playlistNameLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            playlistNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playlistNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset.left = (view.frame.width / 2) - (view.frame.height / 8)
        collectionView.contentInset.right = view.frame.height / 8
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
    }
    
    private func setupTimePicker() {
        view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: playlistNameLabel.bottomAnchor, constant: 35),
            timePicker.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4.5)
        ])
    }
    
    private func setupPlayButton() {
        view.addSubview(playButton)
        
        let heightMultiplier : CGFloat = 1/5
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 50),
            playButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2),
            playButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: heightMultiplier)
        ])
        
        playButton.layer.cornerRadius = (view.frame.width * heightMultiplier) / 2
    }
    
    private func setupMiniPlayer() {
        view.addSubview(miniPlayer)
        
        NSLayoutConstraint.activate([
            miniPlayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            miniPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/9)
        ])
        
//        if musicPlayer.isPlaying {
//            miniPlayer.isHidden = false
//        } else {
//            miniPlayer.isHidden = true
//        }
    }
    
    @objc func playButtonPressed() {
        print("play")
    }
    
    @objc func miniPlayerPlayPressed() {
        print("play")
    }
    
    @objc func miniPlayerNextPressed() {
        print("next")
    }

}

extension NewMainScreenConceptViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewPlaylistCell", for: indexPath) as! NewPlaylistCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let size = CGSize(width: height, height: height)
        return size
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.collectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionView.scrollToNearestVisibleCollectionViewCell()
    }

}

extension UICollectionView {
    func scrollToNearestVisibleCollectionViewCell() {
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .left, animated: true)
        }
    }
}
