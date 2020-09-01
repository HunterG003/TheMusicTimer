//
//  PlaylistSelectionViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class PlaylistSelectionViewController: UIViewController {
    
    private let userPlaylistHeading : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Your Playlists"
        lbl.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        return lbl
    }()
    
    private let userPlaylistCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInset.left = 20
        view.contentInset.right = 20
        view.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        setupUserPlaylist()
    }
    
    private func setupUserPlaylist() {
        view.addSubview(userPlaylistHeading)
        view.addSubview(userPlaylistCollectionView)
        
        userPlaylistCollectionView.delegate = self
        userPlaylistCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            userPlaylistHeading.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userPlaylistHeading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            userPlaylistCollectionView.topAnchor.constraint(equalTo: userPlaylistHeading.bottomAnchor, constant: 10),
            userPlaylistCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userPlaylistCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userPlaylistCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension PlaylistSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edges = view.bounds.width / 2.5
        return CGSize(width: edges, height: edges)
    }
}
