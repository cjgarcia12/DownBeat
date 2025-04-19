import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronomeService = MetronomeService()
    @State private var showingFormPresets = false
    
    // Selected preset
    @State private var selectedPreset: FormPreset?
    
    var body: some View {
        VStack(spacing: 30) {
            // BPM and Time Signature Controls
            HStack(spacing: 20) {
                // BPM Control
                VStack {
                    Text("BPM hi")
                        .font(.headline)
                    
                    HStack {
                        Button(action: decreaseBPM) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                        }
                        
                        Text("\(metronomeService.settings.bpm)")
                            .font(.title)
                            .monospacedDigit()
                            .frame(width: 70)
                        
                        Button(action: increaseBPM) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
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
                    } label: {
                        Text(metronomeService.settings.timeSignature.description)
                            .font(.title)
                            .frame(width: 70)
                            .padding(.horizontal, 5)
                            .background(Color.blue.opacity(0.1))
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
                                .font(.title)
                        }
                        
                        Text("\(metronomeService.settings.phraseLength)")
                            .font(.title)
                            .monospacedDigit()
                            .frame(width: 40)
                        
                        Button(action: increasePhraseLength) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                }
            }
            .padding()
            
            // Beat and Phrase Visual Indicator
            VStack(spacing: 15) {
                Text("Bar \(metronomeService.settings.currentBar) of \(metronomeService.settings.phraseLength)")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(1...metronomeService.settings.timeSignature.beats, id: \.self) { beat in
                        Circle()
                            .fill(beat == metronomeService.settings.currentBeat ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Phrase bar indicator
                HStack(spacing: 5) {
                    ForEach(1...metronomeService.settings.phraseLength, id: \.self) { bar in
                        Rectangle()
                            .fill(bar == metronomeService.settings.currentBar ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 10)
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
            
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
            
            // Form Presets Button
            Button(action: { showingFormPresets = true }) {
                HStack {
                    Image(systemName: "music.note.list")
                    Text("Form Presets")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingFormPresets) {
                FormPresetsView(selectedPreset: $selectedPreset, onPresetSelected: applyPreset)
            }
            
            // Selected Preset Display
            if let preset = selectedPreset {
                HStack {
                    Text("Current Form: \(preset.name)")
                        .font(.headline)
                    
                    Button(action: { selectedPreset = nil }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("PhraseLoop")
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
        metronomeService.settings.phraseLength = min(metronomeService.settings.phraseLength + 1, 16)
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
