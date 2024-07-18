//
//  MIDIController.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 13/07/2024.
//

import Foundation
import AVFoundation

public class MIDIPlayer {
    // Static shared instance
    public static let shared = MIDIPlayer()
    
    public var volume: Float = 0.5
    public var sampler: String = "keyboard"
    public var format: String = "sf2"
    
    private let audioEngine = AVAudioEngine()
    private let unitSampler = AVAudioUnitSampler()
    
    private init() {
        setup()
    }
    
    private func setup() {
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
            at: url, program: 0,
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
