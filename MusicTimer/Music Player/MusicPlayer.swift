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
    fileprivate let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlhEOFY3SExVR1EifQ.eyJpc3MiOiJFN1k0NTRRVE41IiwiaWF0IjoxNjE0NzQ0NTYxLCJleHAiOjE2MzAyOTI5NjF9.6Vll1fVDYISyT2qlyYhtrkvGjVfbgORqq2bnOhHMKSw9Ki9b8DyRq_Rdf3iiw3ZavCBCX118bt9jyVLbt2n8xA" // Regenerated 3/2/2021
    
    fileprivate let controller = SKCloudServiceController()
    fileprivate let systemMusicController = MPMusicPlayerController.systemMusicPlayer
    fileprivate let serviceController = SKCloudServiceController()
    fileprivate var userToken = ""
    fileprivate var userStorefront = ""
    fileprivate var hasSubsetBeenFound = false
    fileprivate var isMoreSongs = true
    var userPlaylists = [Playlist]()
    var selectedPlaylist = 0
    var musicQueue = [Song]()
    var isPlaying = false
    var tempCount = 0
    
    init() {
        systemMusicController.beginGeneratingPlaybackNotifications()
    }
    
    deinit {
        systemMusicController.endGeneratingPlaybackNotifications()
    }
}

// MARK: Setup Functions
extension MusicPlayer {
    func getAuth(completion: @escaping (Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { (auth) in
            switch auth{
            case .authorized:
                self.getUserToken(completion: {
                    completion(true)
                })
                self.getStoreFront()
            case .denied, .notDetermined, .restricted:
                self.controller.requestCapabilities { (capability, err) in
                    if let err = err {
                        print("Error: \(err)")
                        return
                    }
                    completion(false)
                }
            default:
                print("idk")
            }
        }
    }
    
    // Gets User's token and stores it into userToken var
    fileprivate func getUserToken(completion: @escaping () -> Void) {
        controller.requestUserToken(forDeveloperToken: devToken) { (token, err) in
            if let err = err {
                print("Error getting user token: \(err)")
                fatalError()
            }
            guard let token = token else { fatalError("No Token") }
            self.userToken = token
            print("User Token:", self.userToken)
            completion()
        }
    }
    
    // Gets User's storefront and stores it into userStorefront var
    fileprivate func getStoreFront() {
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
                self.tempCount = object.data.count
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
        
//        components.queryItems = [
//            URLQueryItem(name: "limit", value: "1")
//        ]
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                
                // Simple Check for errors
                // TODO: Check for specific errors
                if let _ = json["errors"] {
                    self.tempCount -= 1
                    return
                }
//                print(json)
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
        
        getNumberOfSongsInPlaylist(playlist: playlist) { (num) in
            let numberOfFetches = (num / 100) + 1
            
            for i in 0..<numberOfFetches {
                self.fetchSongs(path: path, offset: i * 100) { (arr) in
                    songs.append(contentsOf: arr)
                    
                    if songs.count == num {
                        completion(songs)
                        print("Number of total songs: \(songs.count)")
                    }
                }
            }
        }
    }
    
    private func getNumberOfSongsInPlaylist(playlist: String, completion: @escaping (Int) -> Void) {
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let realData = json as! Dictionary<String, Any>
                let meta = realData["meta"] as! Dictionary<String, Any>
                print(meta["total"] ?? "")
                let returnValue : Int = meta["total"] as! Int
                completion(returnValue)
            } catch {
            
            }
        }.resume()
    }
    
    private func fetchSongs(path: String, offset: Int, completion: @escaping ([Song]) -> Void) {
        var songs = [Song]()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.music.apple.com"
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let object = try JSONDecoder().decode(PlaylistTracksObject.self, from: data)
                
                for track in object.data {
                    var url = track.attributes.artwork?.url ?? ""
                    url = url.replacingOccurrences(of: "{w}x{h}", with: "500x500")
                    let song = Song(id: track.attributes.playParams.catalogId ?? track.attributes.playParams.id, name: track.attributes.name, artist: track.attributes.artistName, artworkUrl: url, durationInMS: track.attributes.durationInMillis, runTime: track.attributes.durationInMillis / 1000)
                    songs.append(song)
                }
                
                completion(songs)
            } catch {
                print("Error: \(error)")
            }
            
        }.resume()
    }
    
}

// MARK: MT Algorithm
extension MusicPlayer {
    func findSongSubset(songs : [Song], numberOfSongs : Int, timeToFind : Int) -> [Song] {
        
        var dp : [[Bool?]] = Array(repeating: Array(repeating: nil, count: timeToFind + 1), count: numberOfSongs)
        
        if numberOfSongs == 0 || timeToFind < 0 {
            NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
            return []
        }
        
        for i in 0..<numberOfSongs {
            dp[i][0] = true
        }
        
        if songs[0].runTime <= timeToFind {
            dp[0][songs[0].runTime] = true
        }
        
        for i in 1..<numberOfSongs {
            for j in 0..<timeToFind+1 {
                dp[i][j] = (songs[i].runTime <= j) ? (dp[i-1][j] ?? false || dp [i-1][j-songs[i].runTime] ?? false) : dp[i-1][j]
            }
        }
        
        if dp[numberOfSongs-1][timeToFind] == false {
            print("There are no subsets with sum", timeToFind)
            NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
            return []
        }
        
        hasSubsetBeenFound = false
        
        return searchWithRecursion(songs: songs, i: numberOfSongs - 1, timeToFind: timeToFind, subset: [], dp: dp)
    }
    
    private func searchWithRecursion(songs : [Song], i : Int, timeToFind : Int, subset : [Song], dp : [[Bool?]]) -> [Song] {
        
        var newSubset = subset
        
        if i == 0 && timeToFind != 0 && dp[0][timeToFind] ?? false {
            newSubset.append(songs[i])
            hasSubsetBeenFound = true
            return newSubset
        }
        
        if i == 0 && timeToFind == 0 {
            hasSubsetBeenFound = true
            return newSubset
        }
        
        if !hasSubsetBeenFound {
            if dp[i-1][timeToFind] ?? false {
                let b : [Song] = newSubset
                return searchWithRecursion(songs: songs, i: i-1, timeToFind: timeToFind, subset: b, dp: dp)
            }
            
            if timeToFind >= songs[i].runTime && dp[i-1][timeToFind-songs[i].runTime] ?? false {
                newSubset.append(songs[i])
                return searchWithRecursion(songs: songs, i: i-1, timeToFind: timeToFind-songs[i].runTime, subset: newSubset, dp: dp)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
        return []
    }
}

// MARK: The Infamous Play Function
extension MusicPlayer {
    func play(playlist: Playlist, timeToPlay: Int, completion: @escaping (Bool) -> Void) {
        getSongsFromPlaylist(from: playlist.id) { songs in
            self.musicQueue = self.findSongSubset(songs: songs.shuffled(), numberOfSongs: songs.count, timeToFind: timeToPlay)
            if self.musicQueue.isEmpty {
                completion(false)
                return
            }
            var ids = [String]()
            self.musicQueue.forEach { (i) in
                ids.append(i.id)
                print(i.name)
            }
            self.systemMusicController.setQueue(with: ids)
            self.systemMusicController.shuffleMode = .off
            self.systemMusicController.prepareToPlay { (err) in
                if let err = err {
                    fatalError("\(err)")
                }
                self.systemMusicController.play()
                self.isPlaying = true
            }
            completion(true)
//            let duration = timeToPlay / 60
//            let lastPlaylist = LastPlaylist(name: playlist.name, duration: "\(duration) Minutes")
//            if let groupUserDefaults = UserDefaults(suiteName: "group.huntergilliam.musictimer.contents") {
//                groupUserDefaults.set(lastPlaylist.name, forKey: "lastPlaylistName")
//                groupUserDefaults.set(lastPlaylist.duration, forKey: "lastPlaylistDuration")
//            }
        }
    }
}
