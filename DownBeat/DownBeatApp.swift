//
//  DownBeatApp.swift
//  DownBeat
//
//  Created by Christian Garcia on 4/19/25.
//

import SwiftUI
import SwiftData

@main
struct DownBeatApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FormPreset.self,
            MetronomeSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
