//
//  NewMainScreenConceptViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/22/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit

class NewMainScreenConceptViewController: UIViewController, SKCloudServiceSetupViewControllerDelegate {
    
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let activityView = ActivityViewController()
    
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
        view.setValue(UIColor.white, forKey: "textColor")
        return view
    }()
    
    private let playButton : ButtonWithBlurredBackground = {
        let btn = ButtonWithBlurredBackground()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(playButtonPressed), for: .allTouchEvents)
        btn.backgroundColor = .clear
        btn.setTitle("PLAY", for: .normal)
        btn.label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return btn
    }()
    
    private let miniPlayer : MiniNowPlayingView = {
        let view = MiniNowPlayingView(image: UIImage(named: "artwork")!, label: "Circles - Post Malone")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var musicPlayer = MusicPlayer()
    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    private var playlists = [Playlist]()
    private var selectedCell = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupCollectionView()
        setupTimePicker()
        setupPlayButton()
        setupMiniPlayer()
        musicPlayer.getAuth { result in
            if result {
                self.updateUI()
            } else {
                self.showAppleMusicSignUp()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateChanged), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miniViewTapped), name: .init(rawValue: "MiniViewTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createAndShowAlert(_:)), name: .noSongsFound, object: nil)
        playbackStateChanged()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .init("MiniViewTapped"), object: nil)
        NotificationCenter.default.removeObserver(self, name: .noSongsFound, object: nil)
    }
    
    fileprivate func showAppleMusicSignUp() {
        guard SKCloudServiceController.authorizationStatus() == .authorized else { return }
        
        let controller = SKCloudServiceController()
        controller.requestCapabilities { (capability, error) in
            guard error == nil else { return }
            
            if capability.contains(.musicCatalogSubscriptionEligible) && !capability.contains(.musicCatalogPlayback) {
                let options : [SKCloudServiceSetupOptionsKey: Any] = [.action: SKCloudServiceSetupAction.subscribe, .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic]
                let newController = SKCloudServiceSetupViewController()
                newController.delegate = self
                
                newController.load(options: options) { [weak self] (result, error) in
                    guard error == nil else { return }
                    
                    if result {
                        self?.present(newController, animated: true, completion: nil)
                    }
                }
            }
        }

    }
    
    func updateUI() {
        if playlists.isEmpty {
            loadPlaylists(completion: {
                DispatchQueue.main.async {
                    self.playlistNameLabel.text = "\(self.playlists[self.selectedCell].name)"
                    self.updateBackgroundWithAnimation()
                }
            })
        } else {
            playlistNameLabel.text = "\(playlists[selectedCell].name)"
            updateBackgroundWithAnimation()
        }
    }
    
    private func updateBackgroundWithAnimation() {
        UIView.transition(with: backgroundImage, duration: 1, options: .transitionCrossDissolve) {
            self.backgroundImage.downloaded(from: self.playlists[self.selectedCell].artworkUrl, contentMode: .scaleAspectFill, completion: {})
        } completion: { (_) in
            
        }

    }
    
    private func loadPlaylists(completion: @escaping () -> Void) {
        self.createActivityView()
        musicPlayer.getUsersPlaylists { (retrieved) in
            self.playlists = retrieved
            self.musicPlayer.selectedPlaylist = 0
            if self.musicPlayer.tempCount == retrieved.count {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.destroyActivityView()
                }
                completion()
            }
        }
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
        
        if musicPlayer.isPlaying {
            miniPlayer.isHidden = false
        } else {
            miniPlayer.isHidden = true
        }
    }
    
    private func createActivityView() {
        view.addSubview(activityView.view)
    }
    
    private func destroyActivityView() {
        activityView.view.removeFromSuperview()
    }
    
    @objc func playButtonPressed() {
        let timeToPlay = timePicker.countDownDuration
        self.createActivityView()
        musicPlayer.play(playlist: musicPlayer.userPlaylists[selectedCell], timeToPlay: Int(timeToPlay), completion: { bool in
            if bool {
                DispatchQueue.main.async {
                    let vc = NowPlayingViewController()
                    vc.musicPlayer = self.musicPlayer
                    self.present(vc, animated: true)
                }
            }
            DispatchQueue.main.async {
                self.destroyActivityView()
            }
        })
    }
    
    @objc func playbackStateChanged() {
        if musicPlayer.isPlaying {
            miniPlayer.isHidden = false
        } else {
            miniPlayer.isHidden = true
        }
    }
    
    @objc func miniViewTapped() {
        let vc = NowPlayingViewController()
        vc.musicPlayer = self.musicPlayer
        self.present(vc, animated: true)
    }
    
    @objc func createAndShowAlert(_ alert : Notification.Name) {        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error Finding Songs", message: "MusicTimer could not find any set of songs to equal the time you requested to be played. Please try again with either a different playlist or change to amount of time requested.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                
            }))
            self.present(alert, animated: true)
        }
    }

}

extension NewMainScreenConceptViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewPlaylistCell", for: indexPath) as! NewPlaylistCell
        
        cell.imageView.downloaded(from: playlists[indexPath.row].artworkUrl, completion: {})
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let size = CGSize(width: height, height: height)
        return size
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectedCell = self.collectionView.scrollToNearestVisibleCollectionViewCell()
            self.updateUI()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedCell = self.collectionView.scrollToNearestVisibleCollectionViewCell()
        self.updateUI()
    }

}

extension UICollectionView {
    func scrollToNearestVisibleCollectionViewCell() -> Int {
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
            return closestCellIndex
        }
        return closestCellIndex
    }
}
