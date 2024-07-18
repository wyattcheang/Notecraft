//
//  KeyboardModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/07/2024.
//

import Foundation
import AVFoundation

@Observable
class KeyboardModel {
    let midi = MIDIPlayer.shared
//    private let midi = MIDIPlayer(volume: 0.5, sampler: "keyboard")
    
    func play(pitch: Pitch, velocity: UInt8 = 80) {
        midi.play(pitch.MIDINote, velocity: velocity)
    }
    
    func stop(pitch: Pitch) {
        midi.stop(pitch.MIDINote)
    }
}
