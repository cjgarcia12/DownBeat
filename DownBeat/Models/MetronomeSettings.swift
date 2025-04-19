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
    
    init(bpm: Int = 120, timeSignature: TimeSignature = TimeSignature(beats: 4, noteValue: 4), phraseLength: Int = 4, isPlaying: Bool = false) {
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.phraseLength = phraseLength
        self.isPlaying = isPlaying
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