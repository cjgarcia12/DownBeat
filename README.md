# PhraseLoop (DownBeat)

A smart metronome designed to help musicians internalize phrases, sections, and full musical forms.

## Features

### Core Features
1. **Metronome with Phrase Accent**
   - Set BPM, time signature, and phrase length
   - Accents the start of each phrase

2. **Visual Bar + Phrase Counter**
   - Shows current beat in bar
   - Shows current bar in phrase
   - Visual and audible accent at phrase start

3. **Custom Form Presets**
   - Save common musical forms (e.g., 12-bar blues, AABA)
   - Local storage with SwiftData

### Tech Stack
- Language: Swift
- Interface: SwiftUI
- Storage: SwiftData (local only)
- Audio: AVFoundation
- State Management: ObservableObject + @Model

## Setup

1. Clone the repository
2. Open the project in Xcode
3. Add sound files:
   - Add `tick.wav` to Resources (regular metronome tick)
   - Add `accent.wav` to Resources (accented first beat of phrase)
4. Build and run the app

## Future Features
- Form-based click sequences
- Tempo ramps
- iCloud sync
- Preset sharing
- Audio/visual customization
- Practice logging
- Ability to mute specific measures or phrases 