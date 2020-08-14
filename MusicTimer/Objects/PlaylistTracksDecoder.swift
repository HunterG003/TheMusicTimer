//
//  PlaylistTracksDecoder.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/13/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import Foundation

struct PlaylistTracksObject : Codable {
    let data : [PlaylistTracksData]
    let next : String?
    let meta : PlaylistTracksMeta
}

struct PlaylistTracksMeta : Codable {
    let total : Int
}

struct PlaylistTracksData : Codable {
    let attributes : PlaylistTracksAttributes
    let id : String
}

struct PlaylistTracksAttributes : Codable {
    let name : String
    let artistName : String
    let artwork : PlaylistTracksArtwork?
    let durationInMillis : Int
    let playParams : PlayParameters
}

struct PlaylistTracksArtwork : Codable {
    let url : String
}
