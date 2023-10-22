//
//  PadelProWidgetView.swift
//  Padel Pro Watch App WidgetExtension
//
//  Created by Roland Kajatin on 14/10/2023.
//

import SwiftUI
import WidgetKit

struct PadelProWidgetView : View {
    var entry: PadelProTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryRectangular:
            PadelProRectangular(entry: entry)
//        case .accessoryCircular:
//            AkvaAccessoryCircular(progress: entry.data?.progress ?? 0, progressNormalized: entry.data?.progressNormalized ?? 0)
//        case .accessoryInline:
//            AkvaAccessoryInline(target: entry.data?.target ?? 0, progress: entry.data?.progress ?? 0)
//        case .accessoryCorner:
//            AkvaAccessoryCorner(target: entry.data?.target ?? 0, progress: entry.data?.progress ?? 0)
        default:
            PadelProDefault(entry: entry)
        }
    }
}

struct PadelProRectangular: View {
    var entry: PadelProTimelineProvider.Entry
    
    var body: some View {
        VStack {
            HStack {
                Text("Time:")
                Text(entry.date, style: .time)
            }
            
            Text("Emoji:")
            Text(entry.emoji)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PadelProDefault: View {
    var entry: PadelProTimelineProvider.Entry
    
    var body: some View {
        PadelProRectangular(entry: entry)
//            .padding(.all, 5)
            .containerBackground(.background, for: .widget)
    }
}

#Preview(as: .accessoryRectangular) {
    Padel_Pro_Watch_App_Widget()
} timeline: {
    PadelProEntry(date: .now, emoji: "😀")
    PadelProEntry(date: .now, emoji: "🤩")
}
