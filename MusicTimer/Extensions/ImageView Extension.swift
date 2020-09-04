//
//  ImageView Extension.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 9/4/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping () -> Void) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
            completion()
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping () -> Void?) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode, completion: {
            completion()
        })
    }
}
