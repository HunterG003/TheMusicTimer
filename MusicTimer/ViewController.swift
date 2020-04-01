//
//  ViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/1/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: UI Variables
    private let playButton : UIButton = {
        let button = UIButton()
        button.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50))
        button.setTitle("Play", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    // MARK: VIEW DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
    }
    
    func setupView() {
        
    }
    
    func buildButtons() {
        view.addSubview(playButton)
        
    }


}

