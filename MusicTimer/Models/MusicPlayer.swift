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
    private let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlhEOFY3SExVR1EifQ.eyJpc3MiOiJFN1k0NTRRVE41IiwiaWF0IjoxNTg2Mjk1Nzc4LCJleHAiOjE2MDE4NDc3Nzh9.lyTuDTQ0FOdQq_Is2YC1RydTtRsfEPN2-2kY4GQLxbFpxGBiym-3q_N5GPd5d2va4uipMIQeJv_tK8DAy7Ellw" // Invalid After 10/4/2020
    private let controller = SKCloudServiceController()
    private let systemMusicController = MPMusicPlayerController.systemMusicPlayer
    private let appMusicController = MPMusicPlayerController.applicationMusicPlayer
    private var userToken = ""
    private var userStorefront = ""
    
    private var userPlaylists : [Playlist] = []
    
    func getAuth() {
        SKCloudServiceController.requestAuthorization { (auth) in
            switch auth{
            case .authorized:
                print("Authorized")
                self.getUserToken()
                self.getStoreFront()
            default:
                print("idk")
            }
        }
    }
    
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
    
    func getUsersPlaylists() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = "/v1/me/library/playlists"
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { fatalError("No data got returned") }
            
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                print(json)
                let object = try JSONDecoder().decode(UserPlaylistObject.self, from: data)
//                print(object)
                for playlist in object.data {
                    self.userPlaylists.append(Playlist(name: playlist.attributes.name, id: playlist.id))
                    print(playlist.id, playlist.attributes.name)
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    /*
        This function is created to make sure I can play the music.
        This will not be how I play music in finalized version
     
        Have this function to test when Apple fixed their shit. 😠
    */
    
    func testPlay() {
        var playParams : Array<Dictionary<String, Any>> = []
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = "/v1/me/library/playlists/\(userPlaylists[0].id)/tracks"
        
        /*
         This is how you will need to offset to get all songs.
         You will use the meta tag in the json to figure out how many songs you will need to get
         
        components.queryItems = [
            URLQueryItem(name: "offset", value: "0")
        ]
        */
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { fatalError("No data found") }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let jObject = json as! Dictionary<String, Any>
                let jData = jObject["data"] as! Array<Dictionary<String, Any>>
                for newJData in jData {
                    let jAttributes = newJData["attributes"] as! Dictionary<String, Any>
                    let jPlayParams = jAttributes["playParams"] as! Dictionary<String, Any>
                    playParams.append(jPlayParams)
                }
                let object = try JSONDecoder().decode(PlaylistTracksObject.self, from: data)
                for song in object.data {
                    print(song.id, song.attributes.name)
                }
                var paramQueue : [MPMusicPlayerPlayParameters] = []
                for params in playParams {
                    let param = MPMusicPlayerPlayParameters(dictionary: params)
                    paramQueue.append(param!)
                }
                let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: paramQueue)
                self.systemMusicController.setQueue(with: queue)
                self.systemMusicController.play()
            } catch {
                print(error)
            }
        }.resume()
    }
}
