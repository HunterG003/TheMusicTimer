//
//  NewPlaylistCell.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/22/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class NewPlaylistCell: UICollectionViewCell {
    
    let imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "artwork")
        return view
    }()
    
    override func layoutSubviews() {
        setup()
    }
    
    private func setup() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.cornerRadius = 25
        layer.masksToBounds = true
    }
    
}
