import Foundation
import AVFoundation

@Observable
class MIDIPlayer {
    let volume: Float
    let sampler: String
    let format: String
    
    var currentPlayingIndex: Int = 0
    var isPlaying: Bool = false
    var totalIndex: Int = 0
    var velocity: UInt8 = 80
    
    private let audioEngine = AVAudioEngine()
    private let unitSampler = AVAudioUnitSampler()
    private var playingNotes: [UInt8: TimeInterval] = [:]
    
    init(volume: Float = 0.5, sampler: String = "musescore", format: String = "sf2") {
        self.volume = volume
        self.sampler = sampler
        self.format = format
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine.mainMixerNode.volume = volume
        audioEngine.attach(unitSampler)
        audioEngine.connect(unitSampler, to: audioEngine.mainMixerNode, format: nil)
        do {
            try audioEngine.start()
            loadSoundFont()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    private func loadSoundFont() {
        guard let url = Bundle.main.url(forResource: sampler, withExtension: format) else {
            print("Sound font file not found")
            return
        }
        do {
            try unitSampler.loadSoundBankInstrument(at: url,
                                                    program: 1,
                                                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                    bankLSB: UInt8(kAUSampler_DefaultBankLSB))
        } catch {
            print("Error loading sound font: \(error.localizedDescription)")
        }
    }
        
    func play(midiGroup: [Midi], bpm: Int = 75) {
        let quarterNoteDuration = 60.0 / Double(bpm)
        isPlaying = true
        totalIndex = midiGroup.count - 1
        currentPlayingIndex = 0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for (index, midi) in midiGroup.enumerated() {
                if !self.isPlaying { break }
                let noteDuration = quarterNoteDuration * (4.0 * midi.duration)
                Thread.sleep(forTimeInterval: noteDuration/2)
                self.playMidi(midi, duration: noteDuration, index: index)
                Thread.sleep(forTimeInterval: noteDuration/2)
            }
            DispatchQueue.main.async {
                self.stopAll()
            }
        }
    }
    
    private func playMidi(_ midi: Midi, duration: TimeInterval, index: Int) {
        let startTime = CACurrentMediaTime()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentPlayingIndex = index
            for note in midi.notes {
                self.play(note)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                guard let self = self else { return }
                for note in midi.notes {
                    if let noteStartTime = self.playingNotes[note], noteStartTime == startTime {
                        self.stop(note)
                    }
                }
            }
        }
    }
    
    public func play(_ note: UInt8) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unitSampler.startNote(note, withVelocity: self.velocity, onChannel: 0)
            self.playingNotes[note] = CACurrentMediaTime()
        }
    }
    
    public func stop(_ note: UInt8) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unitSampler.stopNote(note, onChannel: 0)
            self.playingNotes.removeValue(forKey: note)
        }
    }
    
    func stopAll() {
        isPlaying = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("stopAll called")
            for note in self.playingNotes.keys {
                self.unitSampler.stopNote(note, onChannel: 0)
            }
            self.playingNotes.removeAll()
            self.currentPlayingIndex = 0
        }
    }
}

