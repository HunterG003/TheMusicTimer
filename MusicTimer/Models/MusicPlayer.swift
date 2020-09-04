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
    fileprivate var hasSubsetBeenFound = false
    var userPlaylists = [Playlist]()
    var selectedPlaylist = 0
    var musicQueue = [Song]()
    
    init() {
        systemMusicController.beginGeneratingPlaybackNotifications()
    }
    
    deinit {
        systemMusicController.endGeneratingPlaybackNotifications()
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

// MARK: MT Specific Functions
extension MusicPlayer {
    func findSongSubset(songs : [Song], numberOfSongs : Int, timeToFind : Int) -> [Song] {
        
        var dp : [[Bool?]] = Array(repeating: Array(repeating: nil, count: timeToFind + 1), count: numberOfSongs)
        
        if numberOfSongs == 0 || timeToFind < 0 {
//            NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
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
//            NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
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
        
//        NotificationCenter.default.post(name: NSNotification.Name.noSongsFound, object: nil)
        return []
    }
}

// MARK: The Infamous Play Function
extension MusicPlayer {
    func play(playlist: Playlist, timeToPlay: Int, completion: @escaping () -> Void) {
        getSongsFromPlaylist(from: playlist.id) { songs in
            self.musicQueue = self.findSongSubset(songs: songs.shuffled(), numberOfSongs: songs.count, timeToFind: timeToPlay)
            var ids = [String]()
            self.musicQueue.forEach { (i) in
                ids.append(i.id)
                print(i.name)
            }
            self.systemMusicController.setQueue(with: ids)
            self.systemMusicController.prepareToPlay { (err) in
                if let err = err {
                    fatalError("\(err)")
                }
                self.systemMusicController.play()
            }
            completion()
        }
    }
}
