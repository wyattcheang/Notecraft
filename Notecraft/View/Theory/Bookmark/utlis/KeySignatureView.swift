//
//  KeySignatureView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 24/06/2024.
//

import SwiftUI

@Observable
class KeySignature {
    var clef: ClefType
    var scale: ScaleType
    var key: KeyType
    
    var accidental: AccidentalType {
        if KeyType.sharpKeysMajor.contains(key) || KeyType.sharpKeysMinor.contains(key) {
            return .sharp
        }
        if KeyType.flatKeysMajor.contains(key) || KeyType.flatKeysMinor.contains(key) {
            return .flat
        } else {
            return .natural
        }
    }
    
    var octaveOnStaff: Int {
        switch clef {
        case .treble: return 4
        case .alto, .tenor: return 3
        case .bass: return 2
        }
    }
    
    init(clef: ClefType = .treble, scale: ScaleType = .major, key: KeyType = .C) {
        self.clef = clef
        self.scale = scale
        self.key = key
    }
    
    var accidentalNotes: [Note] {
            let sharpNotes: [Note] = KeyType.sharpMajorKeysAdded.map { Note($0, .sharp) }
            let flatNotes: [Note] = KeyType.sharpMajorKeysAdded.reversed().map { Note($0, .flat) }
            
            switch scale {
            case .major:
                if let index = KeyType.sharpKeysMajor.firstIndex(of: key) {
                    return Array(sharpNotes.prefix(index + 1))
                } else if let index = KeyType.flatKeysMajor.firstIndex(of: key) {
                    return Array(flatNotes.prefix(index + 1))
                }
            case .minor:
                if let index = KeyType.sharpKeysMinor.firstIndex(of: key) {
                    return Array(sharpNotes.prefix(index + 1))
                } else if let index = KeyType.flatKeysMinor.firstIndex(of: key) {
                    return Array(flatNotes.prefix(index + 1))
                }
            }
            return []
        }
    
    var accidentalOctaves: [Int] {
        if accidental == .flat || (accidental == .sharp && clef == .tenor) {
            return [0, 1, 0, 1, 0, 1, 0].map { $0 + octaveOnStaff}
        }
        if accidental == .sharp {
            return [1, 1, 1, 1, 0, 1, 0].map { $0 + octaveOnStaff }
        }
        return []
    }
    
    var pitchsOnStaff: [Pitch] {
        zip(accidentalNotes, accidentalOctaves).map { note, octave in
            Pitch(note, octave: octave)
        }
    }
}

struct KeySignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    @Binding var keySignature: KeySignature
    var showStaff: Bool = false
        
    var body: some View {
        ZStack {
            if showStaff {
                StaffView(4)
            }
            HStack {
                ClefView(keySignature.clef)
                ForEach(keySignature.pitchsOnStaff, id:\.self) { pitch in
                    let note = pitch.note
                    let offset = pitch.note.baseNote.offset(for: keySignature.clef,
                                                            in: pitch.octave,
                                                            notationSize: notationSize)
                    Text(note.accidental.symbol)
                        .offset(y:  offset)
                }
                .padding(.horizontal, -5)
            }
        }
        .notoMusicSymbolTextStyle()
    }
}


struct ClefView: View {
    let clefType: ClefType
    
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    var offset: CGFloat {
        notationSize.CGFloatValue / 9 * clefType.yOffset
    }
    
    init(_ clefType: ClefType) {
        self.clefType = clefType
    }
    
    var body: some View {
        Text(clefType.symbol)
            .offset(y: offset)
    }
}
