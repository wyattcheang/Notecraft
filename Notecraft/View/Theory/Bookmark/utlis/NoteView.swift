//
//  NoteView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 14/07/2024.
//

import SwiftUI

#Preview("NoteView") {
    VStack {
        NoteView(clef: .treble, pitch: Pitch(Note(.C, .natural), octave: 4))
        NoteView(clef: .treble, pitch: Pitch(Note(.C, .natural), octave: 4), isRest: true)
        NoteView(clef: .treble, 
                 pitch: Pitch(Note(.C, .natural), octave: 4),
                 showAccidental: true,
                 keySignature: KeySignature(clef: .treble, scale: .major, key: .D))
    }
}



struct GroupNoteView: View {
    let midi = MIDIPlayer.shared
//    let midi = MIDIPlayer(volume: 0.6, sampler: "keyboard")
    
    let clef: ClefType
    let pitches: [Pitch]
    var isRest: Bool = false
    var durationType: DurationType = .semibreve
    
    var keySignature: KeySignature?
    var isShowKeySignature: Bool
    var scale: ScaleType?
    
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    var adjOffset: CGFloat {
        return (notationSize.CGFloatValue / 2.5)
    }
    
    var body: some View {
        ZStack {
            StaffView(4)
            HStack {
                HStack(spacing: 0.4) {
                    ForEach(Array(pitches.enumerated()), id: \.offset) { index, pitch in
                        if !isShowKeySignature && pitch.note.accidental != .natural {
                            AccidentalView(pitch: pitch,
                                           clef: clef,
                                           showNatural: false)
                        } else if showAccidental(pitch) {
                            AccidentalView(pitch: pitch,
                                           clef: clef,
                                           showNatural: false)
                        }
                        else if showNaturalAccidental(pitch) {
                            AccidentalView(pitch: pitch,
                                           clef: clef,
                                           showNatural: true)
                        }
                    }
                }
                ZStack {
                    ForEach(Array(pitches.enumerated()), id: \.offset) { index, pitch in
                        let offset: CGFloat = (index > 0 &&
                                               isPitchAdjacent(from: pitches[index - 1],
                                                               to: pitch)) ? adjOffset : 0
                        ZStack {
                            Text(durationType.note)
                                .offset(y: pitch.note.baseNote.offset(for: clef,
                                                                      in: pitch.octave,
                                                                      notationSize: notationSize))
                            let (ledgerLines, direction) = MusicNotation.shared.getLedgerLine(pitch: pitch, clef: clef)
                            if ledgerLines > 0 {
                                LedgerView(amount: ledgerLines, position: direction)
                            }
                        }
                        .offset(x: offset)
                    }
                }
            }
        }
        .notoMusicSymbolTextStyle()
    }
    
    private func showNaturalAccidental(_ pitch: Pitch) -> Bool {
        let inputNote = pitch.note
        guard let note = keySignature?.accidentalNotes.first(where: { $0.baseNote == inputNote.baseNote }) else {
            return false
        }
        return inputNote.accidental == .natural && note.accidental != .natural
    }
    
    private func showAccidental(_ pitch: Pitch) -> Bool {
        guard let note = keySignature?.accidentalNotes.first(where: { $0.baseNote == pitch.note.baseNote }) else {
            // if doesn't exist
            return pitch.note.accidental != .natural
        }
        // if exist
        return note.accidental != pitch.note.accidental
    }
    
    private func isPitchAdjacent(from pitch1: Pitch, to pitch2: Pitch) -> Bool {
        let areNotesAdjacent = pitch1.note.baseNote.next == pitch2.note.baseNote
        let areInSameOctave = pitch1.octave == pitch2.octave
        let areBAndCInAdjacentOctaves = pitch1.note.baseNote == .B && pitch2.note.baseNote == .C && pitch1.octave + 1 == pitch2.octave
        return areNotesAdjacent && (areInSameOctave || areBAndCInAdjacentOctaves)
    }
    
    private func playNote(pitch: Pitch) {
        midi.play(pitch.MIDINote)
    }
}

struct NoteView: View {
    let clef: ClefType
    let pitch: Pitch
    var isRest: Bool = false
    var showAccidental: Bool = false
    var durationType: DurationType = .semibreve
    
    var keySignature: KeySignature?
    var scale: ScaleType?
    
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    var body: some View {
        ZStack {
            StaffView()
            if isRest {
                Text(durationType.rest)
            } else {
                HStack(spacing: -0.4) {
                    ZStack {
                        if showAccidental {
                            AccidentalView(pitch: pitch,
                                           clef: clef,
                                           showNatural: showNaturalAccidental)
                        }
                    }
                    ZStack {
                        Text(durationType.note)
                            .offset(y: pitch.note.baseNote.offset(for: clef,
                                                                  in: pitch.octave,
                                                                  notationSize: notationSize))
                        let (ledgerLines, direction) = MusicNotation.shared.getLedgerLine(pitch: pitch, clef: clef)
                        if ledgerLines > 0 {
                            LedgerView(amount: ledgerLines, position: direction)
                        }
                    }
                }
            }
            
        }
        .notoMusicSymbolTextStyle()
    }
    
    var showNaturalAccidental: Bool {
        let inputNote = pitch.note
        guard let note = keySignature?.accidentalNotes.first(where: { $0.baseNote == inputNote.baseNote }) else {
            return false
        }
        return inputNote.accidental == .natural && note.accidental != .natural
    }
}

struct AccidentalView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let pitch: Pitch
    let clef: ClefType
    var showNatural: Bool = false
    
    var body: some View {
        ZStack {
            Text(showNatural ? pitch.note.accidental.allSymbol : pitch.note.accidental.symbol)
                .offset(y: pitch.note.baseNote.offset(for: clef,
                                                      in: pitch.octave,
                                                      notationSize: notationSize))
            let (ledgerLines, direction) = MusicNotation.shared.getLedgerLine(pitch: pitch, clef: clef)
                        if ledgerLines > 0 {
                            LedgerView(amount: ledgerLines, position: direction)
                        }
        }
    }
}

struct StaffView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let numberOfStaffLines: Int
    
    private var spacing: CGFloat {
        return notationSize.CGFloatValue / 6
    }
    
    init(_ numberOfStaffLines: Int = 1) {
        self.numberOfStaffLines = numberOfStaffLines
    }
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfStaffLines, id: \.self) {_ in
                Text("0x1D11A".toUnicode)
                    .padding(.horizontal, -spacing)
            }
        }
        .notoMusicSymbolTextStyle()
    }
}

struct LedgerView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let amount: Int
    let position: Direction
    
    private var spacing: CGFloat {
        return notationSize.CGFloatValue / 6
    }
    
    private var offset: CGFloat {
        return notationSize.CGFloatValue / 4
    }
    
    var ledgerOffsets: [CGFloat] {
        switch position {
        case .up: return (1...amount).map { CGFloat($0) * -offset - (2 * offset) }
        case .down: return (1...amount).map { CGFloat($0) * offset + (2 * offset) }
        }
    }
    
    var body: some View {
        ForEach(ledgerOffsets, id: \.self) { offset in
            VStack {
                Text("1D116".toUnicode)
                    .offset(y: offset)
                    .padding(.horizontal, -spacing)
            }
            .frame(maxWidth: notationSize.CGFloatValue / 3)
        }
    }
}
