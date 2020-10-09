//
//  ButtonWithBlurredBackground.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/23/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class ButtonWithBlurredBackground: UIButton {
    
    private let blurView : UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let label = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(blurView)
        addSubview(label)
        
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        layer.masksToBounds = true
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        switch state {
        case .normal:
            guard let title = title else { return }
            self.label.text = title
        default:
            print("Wazzgood")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sendActions(for: .touchUpInside)
    }

}
