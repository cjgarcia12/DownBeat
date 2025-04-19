//
//  ContentView.swift
//  DownBeat
//
//  Created by Christian Garcia on 4/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MetronomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FormPreset.self, MetronomeSettings.self], inMemory: true)
}
