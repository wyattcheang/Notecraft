//
//  MIDIController.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 13/07/2024.
//

import Foundation
import AVFoundation

class MIDIPlayer {
    let volume: Float
    let sampler: String
    let format: String
    
    private var audioSession: AVAudioSession?
    private let audioEngine = AVAudioEngine()
    private let unitSampler = AVAudioUnitSampler()
    
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
        if let _ = try? audioEngine.start() {
            loadSoundFont()
        }
    }
    
    private func loadSoundFont() {
        guard let url = Bundle.main.url(forResource: sampler,
                                        withExtension: format) else { return }
        try? unitSampler.loadSoundBankInstrument(
            at: url, program: 1,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }
    
    public func play(_ note: UInt8, velocity: UInt8 = 80) {
        self.unitSampler.startNote(note, withVelocity: velocity, onChannel: 0)
    }

    public func stop(_ note: UInt8) {
        self.unitSampler.stopNote(note, onChannel: 0)
    }
}
