//
//  Watch_Widgets.swift
//  Watch Widgets
//
//  Created by Roland Kajatin on 30/10/2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [SimpleEntry] = [
            SimpleEntry(date: Date())
        ]

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Watch_WidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            BubbleStack()
                .padding()
                .widgetAccentable()
        }
    }
}

@main
struct Watch_Widgets: Widget {
    let kind: String = "Watch_Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Watch_WidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Padel Pro")
        .description("Start a session quickly.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

#Preview(as: .accessoryCircular) {
    Watch_Widgets()
} timeline: {
    SimpleEntry(date: .now)
}
