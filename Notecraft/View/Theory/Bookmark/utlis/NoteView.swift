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
                 isShowingKeySignature: true,
                 keySignature: KeySignature())
    }
}

struct GroupNoteView: View {
    let clef: ClefType
    let pitches: [Pitch]
    var isRest: Bool = false
    var durationType: DurationType = .semibreve
    
    var keySignature: KeySignature?
    var isShowingKeySignature: Bool = true
    var scale: ScaleType?
    
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    var adjOffset: CGFloat {
        return (notationSize.CGFloatValue / 2.5)
    }
    
    var body: some View {
        HStack {
            HStack(spacing: -0.4) {
                ForEach(Array(pitches.enumerated()), id: \.offset) { index, pitch in
                    if accidentalAppearance(pitch) {
                        AccidentalView(pitch: pitch, clef: clef)
                    }
                }
            }
            VStack {
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
    
    private func accidentalAppearance(_ pitch: Pitch) -> Bool {
        let inputNote = pitch.note
        guard let accidentalNote = keySignature?.accidentalNotes.first(where: { $0.baseNote == inputNote.baseNote }) else {
            return false
        }
        
        if isShowingKeySignature {
            return inputNote.accidental != accidentalNote.accidental
        } else {
            return inputNote.accidental != .natural
        }
    }
    
    private func isPitchAdjacent(from pitch1: Pitch, to pitch2: Pitch) -> Bool {
        let areNotesAdjacent = pitch1.note.baseNote.next == pitch2.note.baseNote
        let areInSameOctave = pitch1.octave == pitch2.octave
        let areBAndCInAdjacentOctaves = pitch1.note.baseNote == .B && pitch2.note.baseNote == .C && pitch1.octave + 1 == pitch2.octave
        return areNotesAdjacent && (areInSameOctave || areBAndCInAdjacentOctaves)
    }
}

struct NoteView: View {
    let clef: ClefType
    let pitch: Pitch
    var isRest: Bool = false
    var isShowingKeySignature: Bool = true
    var durationType: DurationType = .semibreve
    
    var keySignature: KeySignature?
    var scale: ScaleType?
    
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    var body: some View {
        if isRest {
            Text(durationType.rest)
        } else {
            HStack(spacing: -0.4) {
                ZStack {
                    if accidentalAppearance {
                        AccidentalView(pitch: pitch, clef: clef)
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
            .padding(.horizontal)
            .notoMusicSymbolTextStyle()
        }
    }
    
    private var accidentalAppearance: Bool {
        let inputNote = pitch.note
        guard let accidentalNote = keySignature?.accidentalNotes.first(where: { $0.baseNote == inputNote.baseNote }) else {
            return false
        }
        
        if isShowingKeySignature {
            return inputNote.accidental != accidentalNote.accidental
        } else {
            return inputNote.accidental != .natural
        }
    }
}

struct AccidentalView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let pitch: Pitch
    let clef: ClefType
    
    var body: some View {
        VStack {
            Text(pitch.note.accidental.allSymbol)
                .offset(y: pitch.note.baseNote.offset(for: clef,
                                                      in: pitch.octave,
                                                      notationSize: notationSize))
        }
    }
}

struct StaffView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let width: CGFloat
    @State private var hwidth: CGFloat = 0
    
    init(width: CGFloat) {
        self.width = width
    }
    
    private var scaledX: CGFloat {
        return width / hwidth
    }

    var body: some View {
        HStack {
            Text(0x1D11A.toUnicode)
                .background(GeometryReader { reader in
                    let size = reader.size
                    Color.clear.onAppear {
                        hwidth = size.width * 0.95
                    }
                })
                .scaleEffect(x: scaledX, y: 1.0)
        }
        .notoMusicSymbolTextStyle()
    }
}

struct LedgerView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    let amount: Int
    let position: LedgerLineDirection
    
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
                Text(0x1D116.toUnicode)
                    .offset(y: offset)
                    .padding(.horizontal, -spacing)
            }
            .frame(maxWidth: notationSize.CGFloatValue / 3)
        }
    }
}
