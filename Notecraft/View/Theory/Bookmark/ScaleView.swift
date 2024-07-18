//
//  ScaleView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 13/07/2024.
//

import SwiftUI

struct ScaleView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    let midi = MIDIPlayer.shared
//    var midi = MIDIPlayer(volume: 0.6, sampler: "keyboard")
    
    @State var keySignature = KeySignature(clef: .treble, scale: .major, key: .C)
    @State var accidental: AccidentalType = .sharp
    @State var octave: Int = 4
    var octaves: ClosedRange<Int> = 2...6
    
    @State private var currentNoteIndex: Int? = nil
    @State private var isPlayingScale: Bool = false
    
    var pitchSet: [Pitch] {
        MusicNotation.shared.generateScale(scaleType: keySignature.scale, key: keySignature.key, startingOctave: octave, order: .both)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    KeySignatureView(keySignature: $keySignature, showStaff: true)
                    ForEach(pitchSet.indices, id: \.self) { index in
                        let pitch = pitchSet[index]
                        Button(action: {
                            playNote(pitch: pitch)
                        }) {
                            NoteView(clef: keySignature.clef, pitch: pitch)
                            .overlay {
                                Text(pitch.text)
                                    .bold()
                                    .font(.caption)
                                    .offset(y: 80)
                            }
                        }
                        .id(index)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 200)
            }
            .onChange(of: currentNoteIndex) { index, _ in
                if let index = index {
                    withAnimation {
                        proxy.scrollTo(index, anchor: .center)
                    }
                }
            }
        }
        List {
            CircleOfFifthsView(scale: keySignature.scale, key: $keySignature.key)
            Group {
                Picker("Clef", selection: $keySignature.clef) {
                    ForEach(ClefType.allCases) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                Picker("Scale", selection: $keySignature.scale) {
                    ForEach(ScaleType.TypeCase) { type in
                        Text(type.nameWithType)
                    }
                }
                Picker("Accidental Preference", selection: $accidental) {
                    ForEach(AccidentalType.preference) { accidental in
                        Text("\(accidental)")
                    }
                }
                Picker("Octave", selection: $octave) {
                    ForEach(octaves, id: \.self) { number in
                        Text("\(number)")
                    }
                }
            }
            Button("Play", action: playScale)
                .disabled(isPlayingScale)
                .buttonStyle(.accentButton)
        }
        .onChange(of: keySignature.clef) {
            guard let octave = BaseNoteType.clefBaseOctaves[keySignature.clef] else {
                return
            }
            self.octave = octave
        }
    }

    private func playNote(pitch: Pitch) {
        midi.play(pitch.MIDINote)
    }
    
    private func stopNote(pitch: Pitch) {
        midi.stop(pitch.MIDINote)
    }
    
    private func playScale() {
        isPlayingScale = true
        var delay: Double = 0
        for (index, pitch) in pitchSet.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                currentNoteIndex = index
                withAnimation {
                    currentNoteIndex = index
                }
                playNote(pitch: pitch)
            }
            delay += 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    currentNoteIndex = nil
                }
                if index == pitchSet.count - 1 {
                    isPlayingScale = false
                }
            }
        }
    }
}

#Preview {
    ScaleView()
}
