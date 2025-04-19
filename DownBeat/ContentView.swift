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
        NavigationView {
            MetronomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FormPreset.self, MetronomeSettings.self], inMemory: true)
}
