//
//  MusicTimerTests.swift
//  MusicTimerTests
//
//  Created by Hunter Gilliam on 10/9/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import XCTest
@testable import MusicTimer

class MusicTimerTests: XCTestCase {

    func testSongAlgorithmPerformance() throws {
        var songs = [Song]()
        
        for _ in 0...200 {
            let randomRunTime = Int.random(in: 120...200)
            let song = Song(id: "", name: "", artist: "", artworkUrl: "", durationInMS: randomRunTime*1000, runTime: randomRunTime)
            songs.append(song)
        }
        
        let timeConstraint = 20 * 60
        
        var queue = [Song]()
        
        measure {
            queue = MusicPlayer().findSongSubset(songs: songs, numberOfSongs: songs.count, timeToFind: timeConstraint)
        }
        
        var sum = 0
        queue.forEach { (song) in
            sum += song.runTime
        }
        
        XCTAssertEqual(sum, timeConstraint)
    }
    
    func testSongAlgorithmPerformanceWithBiggerDataSet() {
        var songs = [Song]()
        
        for _ in 0...500 {
            let randomRunTime = Int.random(in: 120...200)
            let song = Song(id: "", name: "", artist: "", artworkUrl: "", durationInMS: randomRunTime*1000, runTime: randomRunTime)
            songs.append(song)
        }
        
        let timeConstraint = 90 * 60
        
        var queue = [Song]()
        
        measure {
            queue = MusicPlayer().findSongSubset(songs: songs, numberOfSongs: songs.count, timeToFind: timeConstraint)
        }
        
        var sum = 0
        queue.forEach { (song) in
            sum += song.runTime
        }
        
        XCTAssertEqual(sum, timeConstraint)
    }

}
