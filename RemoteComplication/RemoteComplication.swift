//
//  RemoteComplication.swift
//  RemoteComplication
//
//  Created by Jayden Scarpa on 30/04/2025.
//
import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct ComplicationView: View {
    var body: some View {
        Image("ComplicationIcon")
                    .resizable()
                    .scaledToFit()
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
    }
}

@main
struct MyAppComplication: Widget {
    let kind: String = "MyAppComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationView()
        }
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
        .configurationDisplayName("Open the App")
        .description("Tap to launch the app.")
    }
}
