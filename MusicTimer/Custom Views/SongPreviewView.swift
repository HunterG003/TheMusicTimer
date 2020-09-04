//
//  SongPreviewView.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/3/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class SongPreviewView: UIView {
    
    override func layoutSubviews() {
        setupView()
    }
    
    let imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "artwork")
        return view
    }()
    
    let headingLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Up Next"
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return lbl
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let songInfoLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Circles - Post Malone"
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return lbl
    }()
    
    private func setupView() {
        addSubview(imageView)
        addSubview(headingLabel)
        addSubview(separator)
        addSubview(songInfoLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: heightAnchor),
            
            headingLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            headingLabel.topAnchor.constraint(equalTo: topAnchor),
            
            separator.leadingAnchor.constraint(equalTo: headingLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 3),
            separator.heightAnchor.constraint(equalToConstant: 2),
            
            songInfoLabel.leadingAnchor.constraint(equalTo: headingLabel.leadingAnchor),
            songInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            songInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        separator.backgroundColor = .label
    }

}
