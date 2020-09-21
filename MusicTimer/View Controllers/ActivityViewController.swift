//
//  ActivityViewController.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/21/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    private let activityView : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    deinit {
        activityView.stopAnimating()
    }
    
    private func setupView() {
        view.addSubview(activityView)
        
        NSLayoutConstraint.activate([
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityView.topAnchor.constraint(equalTo: view.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    
        activityView.startAnimating()
    }

}
