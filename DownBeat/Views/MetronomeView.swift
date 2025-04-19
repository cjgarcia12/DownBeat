import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronomeService = MetronomeService()
    @State private var showingFormPresets = false
    
    // Selected preset
    @State private var selectedPreset: FormPreset?
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 25) {
                // Settings Grid - BPM, Time Signature, Phrase Length
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        // BPM Control
                        VStack {
                            Text("BPM")
                                .font(.headline)
                            
                            HStack {
                                Button(action: decreaseBPM) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("\(metronomeService.settings.bpm)")
                                    .font(.title2)
                                    .monospacedDigit()
                                    .frame(minWidth: 45)
                                
                                Button(action: increaseBPM) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Time Signature Control
                        VStack {
                            Text("Time")
                                .font(.headline)
                            
                            Menu {
                                Button("4/4") { updateTimeSignature(beats: 4, noteValue: 4) }
                                Button("3/4") { updateTimeSignature(beats: 3, noteValue: 4) }
                                Button("6/8") { updateTimeSignature(beats: 6, noteValue: 8) }
                                Button("5/4") { updateTimeSignature(beats: 5, noteValue: 4) }
                                Button("7/8") { updateTimeSignature(beats: 7, noteValue: 8) }
                                Button("9/8") { updateTimeSignature(beats: 9, noteValue: 8) }
                            } label: {
                                Text(metronomeService.settings.timeSignature.description)
                                    .font(.title2)
                                    .frame(minWidth: 45)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Phrase Length Control
                        VStack {
                            Text("Phrase")
                                .font(.headline)
                            
                            HStack {
                                Button(action: decreasePhraseLength) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("\(metronomeService.settings.phraseLength)")
                                    .font(.title2)
                                    .monospacedDigit()
                                    .frame(minWidth: 30)
                                
                                Button(action: increasePhraseLength) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Count-off Toggle
                    Toggle("Count-off (2 measures)", isOn: $metronomeService.settings.countOffEnabled)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                
                // Beat and Phrase Visual Indicator
                VStack(spacing: 15) {
                    Text("Bar \(metronomeService.settings.currentBar) of \(metronomeService.settings.phraseLength)")
                        .font(.headline)
                    
                    // Current beat indicators with tap gesture for muting
                    HStack(spacing: 8) {
                        ForEach(1...metronomeService.settings.timeSignature.beats, id: \.self) { beat in
                            BeatCircle(
                                beat: beat, 
                                currentBeat: metronomeService.settings.currentBeat,
                                isMuted: metronomeService.settings.isBeatMuted(beat),
                                action: { metronomeService.settings.toggleMuteBeat(beat) }
                            )
                        }
                    }
                    .padding(.bottom, 5)
                    
                    // Phrase bar indicator with tap gesture for muting
                    let columns = min(8, metronomeService.settings.phraseLength)
                    let rows = (metronomeService.settings.phraseLength + columns - 1) / columns
                    
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 5) {
                            ForEach(1...min(columns, metronomeService.settings.phraseLength - row * columns), id: \.self) { col in
                                let barNumber = row * columns + col
                                MeasureRectangle(
                                    barNumber: barNumber,
                                    currentBar: metronomeService.settings.currentBar,
                                    isMuted: metronomeService.settings.isBarMuted(barNumber),
                                    action: { metronomeService.settings.toggleMuteBar(barNumber) }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // Legend for muted indicators
                HStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.red, lineWidth: 2))
                        Text("Muted Beat")
                            .font(.caption)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 14, height: 8)
                            .cornerRadius(2)
                            .overlay(Rectangle().stroke(Color.red, lineWidth: 1).cornerRadius(2))
                        Text("Muted Bar")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 5)
                
                // Play/Stop Button
                Button(action: togglePlayStop) {
                    ZStack {
                        Circle()
                            .fill(metronomeService.settings.isPlaying ? Color.red : Color.green)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: metronomeService.settings.isPlaying ? "stop.fill" : "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                .shadow(radius: 2)
                .padding(.vertical, 5)
                
                // Form Presets Button
                Button(action: { showingFormPresets = true }) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Form Presets")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .shadow(radius: 1)
                .sheet(isPresented: $showingFormPresets) {
                    FormPresetsView(selectedPreset: $selectedPreset, onPresetSelected: applyPreset)
                }
                
                // Selected Preset Display
                if let preset = selectedPreset {
                    HStack {
                        Text("Current Form: \(preset.name)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { selectedPreset = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .navigationTitle("DownBeat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DownBeat")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            // Count-off overlay
            if metronomeService.isCountingOff {
                CountOffOverlay(
                    beat: metronomeService.countOffBeat,
                    bar: metronomeService.countOffBar,
                    timeSignature: metronomeService.settings.timeSignature
                )
            }
        }
    }
    
    // BPM Controls
    private func increaseBPM() {
        let newBPM = min(metronomeService.settings.bpm + 5, 300)
        metronomeService.updateBPM(to: newBPM)
    }
    
    private func decreaseBPM() {
        let newBPM = max(metronomeService.settings.bpm - 5, 40)
        metronomeService.updateBPM(to: newBPM)
    }
    
    // Time Signature Control
    private func updateTimeSignature(beats: Int, noteValue: Int) {
        metronomeService.settings.timeSignature = TimeSignature(beats: beats, noteValue: noteValue)
        
        // If metronome is playing, restart it
        if metronomeService.settings.isPlaying {
            metronomeService.stopMetronome()
            metronomeService.startMetronome()
        }
    }
    
    // Phrase Length Controls
    private func increasePhraseLength() {
        metronomeService.settings.phraseLength = min(metronomeService.settings.phraseLength + 1, 32)
    }
    
    private func decreasePhraseLength() {
        metronomeService.settings.phraseLength = max(metronomeService.settings.phraseLength - 1, 1)
    }
    
    // Play/Stop Toggle
    private func togglePlayStop() {
        if metronomeService.settings.isPlaying {
            metronomeService.stopMetronome()
        } else {
            metronomeService.startMetronome()
        }
    }
    
    // Apply selected preset
    private func applyPreset(preset: FormPreset) {
        metronomeService.stopMetronome()
        
        // Update metronome settings
        metronomeService.settings.bpm = preset.bpm
        metronomeService.settings.timeSignature = preset.timeSignature
        
        // Calculate total phrase length from structure
        let totalBars = preset.structure.reduce(0) { $0 + $1.barCount }
        metronomeService.settings.phraseLength = totalBars
        
        selectedPreset = preset
        showingFormPresets = false
    }
}

// Custom component for the count-off overlay
struct CountOffOverlay: View {
    let beat: Int
    let bar: Int
    let timeSignature: TimeSignature
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Red rectangle with count number
            VStack(spacing: 10) {
                Text("COUNT-OFF")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Bar \(bar) of 2")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                ZStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 180, height: 180)
                        .cornerRadius(15)
                    
                    Text("\(beat)")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Show which beat we're on in the bar
                HStack(spacing: 10) {
                    ForEach(1...timeSignature.beats, id: \.self) { b in
                        Circle()
                            .fill(b == beat ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
        }
        .transition(.opacity)
    }
}

// Custom component for beat circles with mute functionality
struct BeatCircle: View {
    let beat: Int
    let currentBeat: Int
    let isMuted: Bool
    let action: () -> Void
    
    var body: some View {
        Circle()
            .fill(beat == currentBeat 
                  ? Color.blue 
                  : Color.gray.opacity(0.3))
            .frame(width: 20, height: 20)
            .overlay(
                Group {
                    if isMuted {
                        Circle()
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }
            )
            .onTapGesture(perform: action)
    }
}

// Custom component for measure rectangles with mute functionality
struct MeasureRectangle: View {
    let barNumber: Int
    let currentBar: Int
    let isMuted: Bool
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(barNumber == currentBar 
                  ? Color.green 
                  : Color.gray.opacity(0.3))
            .frame(width: 40, height: 18)
            .cornerRadius(5)
            .overlay(
                Group {
                    if isMuted {
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2)
                            .cornerRadius(5)
                    }
                }
            )
            .onTapGesture(perform: action)
    }
} 
