//
//  UserPlaylistDecoder.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/13/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import Foundation

struct UserPlaylistObject : Codable {
    let data : [UserPlaylistData]
    let meta : UserPlaylistMeta
}

struct UserPlaylistMeta : Codable {
    let total : Int
}

struct UserPlaylistData : Codable {
    let attributes : UserPlaylistAttributes
    let href : String
    let id : String
    let type : String
}

struct UserPlaylistAttributes : Codable {
    let name : String
    let artwork : UserPlaylistArtwork?
    let playParams : UserPlaylistPlayParams
}

struct UserPlaylistArtwork : Codable {
    let url : String
}
struct UserPlaylistPlayParams : Codable {
    let globalId : String?
    let id : String
    let kind : String
}
