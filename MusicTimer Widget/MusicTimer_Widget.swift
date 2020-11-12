//
//  MusicTimer_Widget.swift
//  MusicTimer Widget
//
//  Created by Hunter Gilliam on 11/2/20.
//  Copyright © 2020 Hunter Gilliam. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        let playlist = LastPlaylist(name: "Vibes", duration: "30 Minutes")
        return Entry(date: Date(), lastPlaylist: playlist)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let playlist = LastPlaylist(name: "Vibes", duration: "30 Minutes")
        let entry = Entry(date: Date(), lastPlaylist: playlist)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        if let groupUserDefaults = UserDefaults(suiteName: "group.huntergilliam.musictimer.contents") {
            let duration = groupUserDefaults.string(forKey: "lastPlaylistDuration") ?? "Unknown"
            let name = groupUserDefaults.string(forKey: "lastPlaylistName") ?? "Unknown"
            let lastPlaylist = LastPlaylist(name: name, duration: duration)
            let entry = Entry(date: Date().advanced(by: 1000), lastPlaylist: lastPlaylist)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let lastPlaylist: LastPlaylist
}

struct MusicTimer_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.pink.ignoresSafeArea()
            VStack {
                Spacer()
//                entry.lastPlaylist.image
//                    .resizable()
//                    .scaledToFit()
//                    .cornerRadius(10.0)
//                    .shadow(radius: 10)
                Text(entry.lastPlaylist.name)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(entry.lastPlaylist.duration)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
            }
        }
    }
}

@main
struct MusicTimer_Widget: Widget {
    let kind: String = "MusicTimer_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MusicTimer_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MusicTimer Widget")
        .description("Displays some information from MusicTimer")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct MusicTimer_Widget_Previews: PreviewProvider {
    static var previews: some View {
        let playlist = LastPlaylist(name: "Vibes That have a long name :)", duration: "30 Minutes")
        MusicTimer_WidgetEntryView(entry: Entry(date: Date(), lastPlaylist: playlist))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
