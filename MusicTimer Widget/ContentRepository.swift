//
//  ContentRepository.swift
//  MusicTimer
//
//  Created by Hunter Gilliam on 11/2/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import Foundation
import Combine

extension FileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.huntergilliam.musictimer.contents")!
    }
}

