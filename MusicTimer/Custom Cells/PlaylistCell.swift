//
//  PlaylistCell.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class PlaylistCell: UICollectionViewCell {
    
    let imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "artwork")
        return view
    }()
    
    let title : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Temporary"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textAlignment = .center
        return lbl
    }()
    
    override func layoutSubviews() {
        setupView()
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(title)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
}
