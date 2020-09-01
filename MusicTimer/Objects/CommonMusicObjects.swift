//
//  CommonMusicObjects.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 4/13/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import Foundation

struct Artwork {
    let width : Int
    let height : Int
    let url : String
}

struct PlayParameters : Codable {
    let id : String
    let kind : String
    let catalogId : String?
}
