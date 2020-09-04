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
    fileprivate let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlhEOFY3SExVR1EifQ.eyJpc3MiOiJFN1k0NTRRVE41IiwiaWF0IjoxNTk4Mjg2MjE1LCJleHAiOjE2MTM4NDE4MTV9.1-jRU6Zf2N5H-LlpAXxqjIdHOugU4zhMlR9HEfnVXKc73Z5KO1aKOxlMXasYROzQSmECu-1ygtZrSKJ5AMkbaA" // Need to move this to a web server
    
    fileprivate let controller = SKCloudServiceController()
    fileprivate let systemMusicController = MPMusicPlayerController.systemMusicPlayer
    fileprivate let appMusicController = MPMusicPlayerController.applicationMusicPlayer
    fileprivate var userToken = ""
    fileprivate var userStorefront = ""
    var userPlaylists = [Playlist]()
    
    /*
        This function is created to make sure I can play the music.
        This will not be how I play music in finalized version
    */
    
    func testPlay() {
        var songIds = [String]()
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = "/v1/me/library/playlists/p.LV0PBWquaO7Z6B/tracks"
        
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
                let object = try JSONDecoder().decode(PlaylistTracksObject.self, from: data)
                
                for song in object.data {
                    songIds.append(song.attributes.playParams.catalogId ?? song.attributes.playParams.id)
                }
                
                self.systemMusicController.beginGeneratingPlaybackNotifications()
                self.systemMusicController.setQueue(with: songIds)
                self.systemMusicController.play()
            } catch {
                print(error)
            }
        }.resume()
    }
}

// MARK: Setup Functions
extension MusicPlayer {
    func getAuth() {
        SKCloudServiceController.requestAuthorization { (auth) in
            switch auth{
            case .authorized:
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
}

// MARK: Retrieve Playlists Functions
extension MusicPlayer {
    
    func getUsersPlaylists(completion: @escaping ([Playlist]) -> Void) {
        var playlists = [Playlist]()
        
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
                let object = try JSONDecoder().decode(UserPlaylistObject.self, from: data)
                for playlist in object.data {
                    if playlist.attributes.artwork?.url == nil {
                        self.getImageForAPlaylist(playlist: playlist.id, completion: { url in
                            let new = Playlist(name: playlist.attributes.name, id: playlist.id, artworkUrl: url)
                            playlists.append(new)
                            self.userPlaylists.append(new)
                            completion(playlists)
                        })
                        
                    } else {
                        var url = playlist.attributes.artwork?.url ?? ""
                        url = url.replacingOccurrences(of: "{w}", with: "500")
                        url = url.replacingOccurrences(of: "{h}", with: "500")
                        playlists.append(Playlist(name: playlist.attributes.name, id: playlist.id, artworkUrl: url))
                    }
                }
                self.userPlaylists = playlists
                completion(playlists)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    private func getImageForAPlaylist(playlist: String, completion: @escaping (String) -> Void) {
        let path = "/v1/me/library/playlists/\(playlist)/tracks"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: "limit", value: "1")
        ]
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                let jsonData = json["data"] as! Array<Dictionary<String, Any>>
                let attributes = jsonData[0]["attributes"] as! Dictionary<String, Any>
                let artwork = attributes["artwork"] as! Dictionary<String, Any>
                var url = artwork["url"] as! String
                url = url.replacingOccurrences(of: "{w}x{h}", with: "500x500")
                completion(url)
            } catch {
                print("Error: \(error)")
            }
            
        }.resume()
    }
    
}

// MARK: Fetch Songs Functions
extension MusicPlayer {
    
    func getSongsFromPlaylist(from playlist: String, completion: @escaping ([Song]) -> Void) {
        var songs = [Song]()
        
        let path = "/v1/me/library/playlists/\(playlist)/tracks"
        
        self.fetchSongs(path: path) { (arr) in
            songs.append(contentsOf: arr)
            completion(songs)
        }
    }
    
    private func fetchSongs(path: String, completion: @escaping ([Song]) -> Void) {
        var songs = [Song]()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = path
        
//        components.queryItems = [
//            URLQueryItem(name: "offset", value: offset)
//        ]
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                
                let object = try JSONDecoder().decode(PlaylistTracksObject.self, from: data)
                
                for track in object.data {
                    let song = Song(id: track.attributes.playParams.catalogId ?? track.attributes.playParams.id, name: track.attributes.name, artist: track.attributes.artistName, artworkUrl: track.attributes.artwork?.url ?? nil, durationInMS: track.attributes.durationInMillis)
                    songs.append(song)
                }
                
                completion(songs)
            } catch {
                print("Error: \(error)")
            }
            
        }.resume()
    }
    
}
