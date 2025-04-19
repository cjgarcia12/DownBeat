import Foundation
import AVFoundation

class MetronomeService: ObservableObject {
    @Published var settings: MetronomeSettings
    
    // Published properties for UI to observe
    @Published var isCountingOff = false
    @Published var countOffBeat = 0
    @Published var countOffBar = 0
    
    private var timer: Timer?
    
    // Multiple audio players to avoid interference
    private var tickPlayer1: AVAudioPlayer?
    private var tickPlayer2: AVAudioPlayer?
    private var accentPlayer1: AVAudioPlayer?
    private var accentPlayer2: AVAudioPlayer?
    private var countOffPlayer: AVAudioPlayer?
    
    // Track which player to use next (alternating to avoid cutting off sounds)
    private var useFirstTickPlayer = true
    private var useFirstAccentPlayer = true
    
    // Audio session
    private var audioSession: AVAudioSession?
    
    // This tracks the actual next beat to play
    private var nextBeatToPlay = 1
    private var nextBarToPlay = 1
    
    // Count-off state
    private var countOffBeatsPlayed = 0
    private var totalCountOffBeats = 0
    private var shouldTransitionAfterCountOff = false
    
    init(settings: MetronomeSettings = MetronomeSettings()) {
        self.settings = settings
        setupAudioSession()
        setupSounds()
    }
    
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupSounds() {
        // Create duplicate players for each sound to avoid timing issues
        if let tickURL = Bundle.main.url(forResource: "tick", withExtension: "wav") {
            do {
                tickPlayer1 = try AVAudioPlayer(contentsOf: tickURL)
                tickPlayer1?.prepareToPlay()
                tickPlayer1?.volume = 0.7
                
                tickPlayer2 = try AVAudioPlayer(contentsOf: tickURL)
                tickPlayer2?.prepareToPlay()
                tickPlayer2?.volume = 0.7
                
                // Use the same sound for count-off but different volume
                countOffPlayer = try AVAudioPlayer(contentsOf: tickURL)
                countOffPlayer?.prepareToPlay()
                countOffPlayer?.volume = 0.5
            } catch {
                print("Failed to load tick sound: \(error)")
            }
        }
        
        if let accentURL = Bundle.main.url(forResource: "accent", withExtension: "wav") {
            do {
                accentPlayer1 = try AVAudioPlayer(contentsOf: accentURL)
                accentPlayer1?.prepareToPlay()
                accentPlayer1?.volume = 1.0
                
                accentPlayer2 = try AVAudioPlayer(contentsOf: accentURL)
                accentPlayer2?.prepareToPlay()
                accentPlayer2?.volume = 1.0
            } catch {
                print("Failed to load accent sound: \(error)")
            }
        }
    }
    
    func startMetronome() {
        stopMetronome() // Ensure any existing timer is invalidated
        
        // Reset state
        settings.isPlaying = true
        shouldTransitionAfterCountOff = false
        
        // Initialize counters
        nextBeatToPlay = 1
        nextBarToPlay = 1
        
        // Reset player tracking
        useFirstTickPlayer = true
        useFirstAccentPlayer = true
        
        // Update display to match what will play
        settings.currentBeat = nextBeatToPlay
        settings.currentBar = nextBarToPlay
        
        // Calculate interval between beats
        let interval = 60.0 / Double(settings.bpm)
        
        // Determine if we should count off
        if settings.countOffEnabled {
            // Count off for 2 measures (e.g., 8 beats in 4/4 time)
            totalCountOffBeats = settings.timeSignature.beats * 2
            countOffBeatsPlayed = 0
            
            // Initialize count-off display state
            isCountingOff = true
            countOffBeat = 1
            countOffBar = 1
            
            print("Starting count-off: \(totalCountOffBeats) beats total")
        } else {
            isCountingOff = false
            countOffBeat = 0
            countOffBar = 0
        }
        
        // Schedule the timer
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        // Fire immediately for the first beat
        timerFired()
    }
    
    @objc private func timerFired() {
        if shouldTransitionAfterCountOff {
            // Handle the transition to regular playback
            shouldTransitionAfterCountOff = false
            isCountingOff = false
            nextBeatToPlay = 1
            nextBarToPlay = 1
            settings.currentBeat = 1
            settings.currentBar = 1
            
            // Play the first regular beat
            handleRegularBeat()
            return
        }
        
        if isCountingOff {
            handleCountOffBeat()
        } else {
            handleRegularBeat()
        }
    }
    
    private func handleCountOffBeat() {
        // Only continue if we haven't finished the count-off
        if countOffBeatsPlayed < totalCountOffBeats {
            // Calculate which beat and bar we're on (1-based indexing)
            countOffBeat = (countOffBeatsPlayed % settings.timeSignature.beats) + 1
            countOffBar = (countOffBeatsPlayed < settings.timeSignature.beats) ? 1 : 2
            
            print("Count-off: bar \(countOffBar), beat \(countOffBeat), played \(countOffBeatsPlayed + 1) of \(totalCountOffBeats)")
            
            // Play the sound
            playCountOffSound()
            
            // Increment counter for next beat
            countOffBeatsPlayed += 1
            
            // Check if this was the last beat of the count-off
            if countOffBeatsPlayed >= totalCountOffBeats {
                print("Count-off complete, scheduling transition to regular playback")
                shouldTransitionAfterCountOff = true
            }
        }
    }
    
    private func handleRegularBeat() {
        // Update display to match what we're about to play
        settings.currentBeat = nextBeatToPlay
        settings.currentBar = nextBarToPlay
        
        // Check if current beat is muted
        if !settings.isBeatMuted(settings.currentBeat) && !settings.isBarMuted(settings.currentBar) {
            // Play accent on the first beat of the first bar in a phrase
            if settings.currentBeat == 1 && settings.currentBar == 1 {
                playAccentSound()
            } else {
                playTickSound()
            }
        }
        
        // Calculate the next beat for the next timer fire
        updateNextBeatAndBar()
    }
    
    private func updateNextBeatAndBar() {
        // Update to the next beat for regular playback
        if nextBeatToPlay >= settings.timeSignature.beats {
            // We're at the last beat of the bar, so wrap around to beat 1
            nextBeatToPlay = 1
            
            // Update the bar counter
            if nextBarToPlay >= settings.phraseLength {
                // We're at the last bar of the phrase, so wrap around
                nextBarToPlay = 1
            } else {
                // Move to the next bar
                nextBarToPlay += 1
            }
        } else {
            // Just move to the next beat in the current bar
            nextBeatToPlay += 1
        }
    }
    
    func stopMetronome() {
        timer?.invalidate()
        timer = nil
        settings.isPlaying = false
        isCountingOff = false
        countOffBeat = 0
        countOffBar = 0
        countOffBeatsPlayed = 0
        shouldTransitionAfterCountOff = false
    }
    
    func updateBPM(to newBPM: Int) {
        settings.bpm = newBPM
        
        // If metronome is playing, restart it with the new BPM
        if settings.isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
    
    private func playTickSound() {
        // Alternate between two players to avoid cutting off sound
        if useFirstTickPlayer {
            tickPlayer1?.currentTime = 0
            tickPlayer1?.play()
        } else {
            tickPlayer2?.currentTime = 0
            tickPlayer2?.play()
        }
        useFirstTickPlayer.toggle()
    }
    
    private func playAccentSound() {
        // Alternate between two players to avoid cutting off sound
        if useFirstAccentPlayer {
            accentPlayer1?.currentTime = 0
            accentPlayer1?.play()
        } else {
            accentPlayer2?.currentTime = 0
            accentPlayer2?.play()
        }
        useFirstAccentPlayer.toggle()
    }
    
    private func playCountOffSound() {
        countOffPlayer?.currentTime = 0
        countOffPlayer?.play()
    }
} 
