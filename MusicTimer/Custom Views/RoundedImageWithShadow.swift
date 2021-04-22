//
//  RoundedImageWithShadow.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/10/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class RoundedImageWithShadow: UIView {
    
    private var cornerRadius : CGFloat
    private let shapeLayer = CAShapeLayer()
    
    private let imageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "artwork")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        imageView.layer.cornerRadius = self.cornerRadius
        imageView.layer.masksToBounds = true
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
    }
    
    func updateImage(with image: UIImage) {
        self.imageView.image = image
        layer.shadowColor = image.averageColor?.withAlphaComponent(1).cgColor ?? UIColor.blue.cgColor
    }
    
}
