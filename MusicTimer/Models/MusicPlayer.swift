//
//  MusicPlayer.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/7/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import MediaPlayer
import StoreKit

class MusicPlayer {
    let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlhEOFY3SExVR1EifQ.eyJpc3MiOiJFN1k0NTRRVE41IiwiaWF0IjoxNTg2Mjk1Nzc4LCJleHAiOjE2MDE4NDc3Nzh9.lyTuDTQ0FOdQq_Is2YC1RydTtRsfEPN2-2kY4GQLxbFpxGBiym-3q_N5GPd5d2va4uipMIQeJv_tK8DAy7Ellw" // Invalid After 10/4/2020
    let controller = SKCloudServiceController()
    
    private var userToken = ""
    private var userStorefront = ""
    
    // Gets User's token and stores it into userToken var
    func getUserToken() {
        controller.requestUserToken(forDeveloperToken: devToken) { (token, err) in
            if let err = err {
                print("Error getting user token: \(err)")
                fatalError()
            }
            guard let token = token else { fatalError("No Token") }
            self.userToken = token
            print("User Token:", self.userToken)
        }
    }
    
    // Gets User's storefront and stores it into userStorefront var
    func getStoreFront() {
        controller.requestStorefrontCountryCode { (store, err) in
            if let err = err {
                print("Error getting storefront: \(err)")
                fatalError()
            }
            guard let store = store else { fatalError("No Storefront Code") }
            self.userStorefront = store
            print("Storefront Code:", self.userStorefront)
        }
    }
    
    func testAPIRequest() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = "/v1/catalog/\(userStorefront)/search"
        
        components.queryItems = [
            URLQueryItem(name: "term", value: "workouts"),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "types", value: "playlists")
        ]
        
        let url = components.url
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { fatalError() }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                
            }
        }.resume()
    }
}
