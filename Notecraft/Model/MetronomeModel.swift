//
//  MetronomeModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 30/06/2024.
//
import Foundation
import AVFoundation

@Observable
class MetronomeModel {
    var onBeat: Bool = false
    var division: Int = 1 {
        didSet { updateInterval() }
    }
    var beat: Int = 4 {
        didSet { updateInterval() }
    }
    var bpm: Int = 120 {
        didSet { updateInterval() }
    }
    
    private var timer: Timer?
    private let audioEngine = AVAudioEngine()
    private let unitSampler = AVAudioUnitSampler()
    private var tapTimes: [Date] = []
    private var currentSubdivision: Int = 0
    private var currentBeat: Int = 1
    private var isTicking: Bool = false
    private var interval: Double { 60.0 / Double(bpm * division) }
    
    init() {
        setupAudioEngine()
    }
    
    deinit {
        if audioEngine.isRunning {
            audioEngine.disconnectNodeOutput(unitSampler)
            audioEngine.detach(unitSampler)
            audioEngine.stop()
        }
    }
    
    private func setupAudioEngine() {
        audioEngine.mainMixerNode.volume = 0.6
        audioEngine.attach(unitSampler)
        audioEngine.connect(unitSampler, to: audioEngine.mainMixerNode, format: nil)
        if let _ = try? audioEngine.start() {
            loadSoundFont()
        }
    }
    
    private func loadSoundFont() {
        guard let url = Bundle.main.url(forResource: "metronome", withExtension: "sf2") else { return }
        try? unitSampler.loadSoundBankInstrument(
            at: url, program: 0,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }
    
    private func calculateBPM() {
        guard tapTimes.count > 2 else { return }
        let intervals = zip(tapTimes.dropFirst(), tapTimes).map { $0.timeIntervalSince($1) }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        bpm = min(Int(60.0 / averageInterval), 400)
    }
    
    private func updateBeatAndSubdivision() {
        currentSubdivision = (currentSubdivision + 1) % division
        if currentSubdivision == 0 {
            currentBeat = (currentBeat % beat) + 1
        }
    }
    
    private func determineTickSound() -> (UInt8, UInt8, Bool) {
        if currentSubdivision == 0 {
            if currentBeat == 1 {
                return (76, 127, true) // Downbeat
            } else {
                return (77, 80, true) // Upbeat
            }
        } else {
            return (78, 75, false) // Subdivision
        }
    }
    
    private func playTick() {
        let (note, velocity, shouldToggleOnBeat) = determineTickSound()
        tick(note: note, velocity:velocity , toggleOnBeat: shouldToggleOnBeat)
        updateBeatAndSubdivision()
    }
    
    
    private func tick(note: UInt8, velocity: UInt8, toggleOnBeat: Bool) {
        if toggleOnBeat {
            onBeat = true
        }
        unitSampler.startNote(note, withVelocity: velocity, onChannel: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.unitSampler.stopNote(note, onChannel: 0)
            if toggleOnBeat {
                self.onBeat = false
            }
        }
    }
    
    @objc private func handleTick() {
        playTick()
    }
    
    private func updateInterval() {
        guard isTicking else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(handleTick), userInfo: nil, repeats: true)
    }
    
    // control from UI
    func startTick() {
        stopTick()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(handleTick), userInfo: nil, repeats: true)
        isTicking = true
    }
    
    func stopTick() {
        timer?.invalidate()
        timer = nil
        isTicking = false
        currentSubdivision = 0
        currentBeat = 1
    }
    
    func handleTap() {
        tapTimes.append(Date())
        if tapTimes.count > 10 {
            tapTimes.removeFirst()
        }
        calculateBPM()
    }
}


