//
//  PadelProTimelineProvider.swift
//  Padel Pro Watch App WidgetExtension
//
//  Created by Roland Kajatin on 14/10/2023.
//

import SwiftUI
import WidgetKit

struct PadelProEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct PadelProTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PadelProEntry {
        PadelProEntry(date: Date(), emoji: "😀")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PadelProEntry) -> ()) {
        let entry = PadelProEntry(date: Date(), emoji: "😀")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PadelProEntry>) -> ()) {
        var entries: [PadelProEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = PadelProEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
