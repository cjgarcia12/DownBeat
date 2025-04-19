import Foundation
import SwiftData

@Model
final class MetronomeSettings {
    // Basic metronome settings
    var bpm: Int
    var timeSignature: TimeSignature
    var phraseLength: Int // Number of bars in a phrase
    var isPlaying: Bool
    
    // For visual display
    var currentBeat: Int = 1
    var currentBar: Int = 1
    
    // Mute settings
    var mutedBeats: [Int] = [] // Beats that should be muted (1-based index)
    var mutedBars: [Int] = [] // Bars that should be muted (1-based index)
    var countOffEnabled: Bool = true
    
    init(bpm: Int = 120, timeSignature: TimeSignature = TimeSignature(beats: 4, noteValue: 4), phraseLength: Int = 4, isPlaying: Bool = false) {
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.phraseLength = phraseLength
        self.isPlaying = isPlaying
    }
    
    // Helper functions for muting
    func toggleMuteBeat(_ beat: Int) {
        if mutedBeats.contains(beat) {
            mutedBeats.removeAll { $0 == beat }
        } else {
            mutedBeats.append(beat)
        }
    }
    
    func toggleMuteBar(_ bar: Int) {
        if mutedBars.contains(bar) {
            mutedBars.removeAll { $0 == bar }
        } else {
            mutedBars.append(bar)
        }
    }
    
    func isBeatMuted(_ beat: Int) -> Bool {
        return mutedBeats.contains(beat)
    }
    
    func isBarMuted(_ bar: Int) -> Bool {
        return mutedBars.contains(bar)
    }
}

struct TimeSignature: Codable, Hashable {
    var beats: Int
    var noteValue: Int
    
    var description: String {
        return "\(beats)/\(noteValue)"
    }
}

@Model
final class FormPreset {
    var name: String
    var bpm: Int
    var timeSignature: TimeSignature
    var structure: [PhraseSection]
    var timestamp: Date
    
    init(name: String, bpm: Int, timeSignature: TimeSignature, structure: [PhraseSection], timestamp: Date = Date()) {
        self.name = name
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.structure = structure
        self.timestamp = timestamp
    }
}

struct PhraseSection: Codable, Hashable {
    var name: String // e.g., "A", "B", "Verse", "Chorus"
    var barCount: Int
    var isMuted: Bool = false
}

// Common musical forms as preset examples
extension FormPreset {
    static func twelveBarBlues() -> FormPreset {
        return FormPreset(
            name: "12-Bar Blues",
            bpm: 120,
            timeSignature: TimeSignature(beats: 4, noteValue: 4),
            structure: [
                PhraseSection(name: "I", barCount: 4),
                PhraseSection(name: "IV", barCount: 2),
                PhraseSection(name: "I", barCount: 2),
                PhraseSection(name: "V", barCount: 1),
                PhraseSection(name: "IV", barCount: 1),
                PhraseSection(name: "I", barCount: 2)
            ]
        )
    }
    
    static func thirtyTwoBarForm() -> FormPreset {
        return FormPreset(
            name: "32-Bar AABA",
            bpm: 120,
            timeSignature: TimeSignature(beats: 4, noteValue: 4),
            structure: [
                PhraseSection(name: "A", barCount: 8),
                PhraseSection(name: "A", barCount: 8),
                PhraseSection(name: "B", barCount: 8),
                PhraseSection(name: "A", barCount: 8)
            ]
        )
    }
} 