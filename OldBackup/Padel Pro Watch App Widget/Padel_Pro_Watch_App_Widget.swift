//
//  Padel_Pro_Watch_App_Widget.swift
//  Padel Pro Watch App Widget
//
//  Created by Roland Kajatin on 14/10/2023.
//

import SwiftUI
import WidgetKit

@main
struct Padel_Pro_Watch_App_Widget: Widget {
    let kind: String = "Padel_Pro_Watch_App_Widget"
    
    var families: [WidgetFamily] {
#if os(iOS)
        return [.accessoryCircular, .accessoryRectangular, .systemSmall]
#elseif os(watchOS)
        return [.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner]
#endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PadelProTimelineProvider()) { entry in
            PadelProWidgetView(entry: entry)
        }
        .configurationDisplayName("Padel Pro Widget")
        .description("Show workout activity and game score information")
        .supportedFamilies(families)
    }
}
