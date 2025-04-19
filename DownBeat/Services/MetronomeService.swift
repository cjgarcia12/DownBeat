import Foundation
import AVFoundation

class MetronomeService: ObservableObject {
    @Published var settings: MetronomeSettings
    
    private var timer: Timer?
    
    // Multiple audio players to avoid interference
    private var tickPlayer1: AVAudioPlayer?
    private var tickPlayer2: AVAudioPlayer?
    private var accentPlayer1: AVAudioPlayer?
    private var accentPlayer2: AVAudioPlayer?
    
    // Track which player to use next (alternating to avoid cutting off sounds)
    private var useFirstTickPlayer = true
    private var useFirstAccentPlayer = true
    
    // Audio session
    private var audioSession: AVAudioSession?
    
    // This tracks the actual next beat to play
    private var nextBeatToPlay = 1
    private var nextBarToPlay = 1
    
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
        
        // Initialize counters
        nextBeatToPlay = 1
        nextBarToPlay = 1
        
        // Update display to match what will play
        settings.currentBeat = nextBeatToPlay
        settings.currentBar = nextBarToPlay
        
        // Reset player tracking
        useFirstTickPlayer = true
        useFirstAccentPlayer = true
        
        // Calculate interval between beats
        let interval = 60.0 / Double(settings.bpm)
        
        // Play the first beat immediately
        playAppropriateSound()
        
        // Then immediately calculate the next beat to play
        updateNextBeatAndBar()
        
        // Schedule the timer for subsequent beats - use a slightly shorter interval
        // to ensure the timer fires just before the beat should play
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func timerFired() {
        // Update display to match what we're about to play
        settings.currentBeat = nextBeatToPlay
        settings.currentBar = nextBarToPlay
        
        // Play the sound for the current beat
        playAppropriateSound()
        
        // Then calculate the next beat for the next timer fire
        updateNextBeatAndBar()
    }
    
    private func playAppropriateSound() {
        // Play accent on the first beat of the first bar in a phrase
        if settings.currentBeat == 1 && settings.currentBar == 1 {
            playAccentSound()
        } else {
            playTickSound()
        }
    }
    
    private func updateNextBeatAndBar() {
        // Update to the next beat
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
} 
