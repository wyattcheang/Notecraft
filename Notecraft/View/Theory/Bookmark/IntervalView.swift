//
//  Interval.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 14/07/2024.
//

import SwiftUI

struct IntervalView: View {
    @Environment(\.midi) var midi: MIDIPlayer
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    @State var keySignature = KeySignature(clef: .treble, scale: .major, key: .C)
    @State var accidental: AccidentalType = .sharp
    @State var octave: Int = 4
    
    @State private var isShowKeySignature: Bool = true
    @State private var isPlayingScale: Bool = false
    @State private var intervalQuality: IntervalQualityType = .major
    @State private var intervalPosition: IntervalPositionType = .second
    
    var interval: Interval? {
        guard let interval = Interval(quality: intervalQuality, position: intervalPosition) else { return nil }
        return interval
    }
    
    var pitchGroup: [Pitch] {
        let basePitch = Pitch(keySignature.key.note, octave: octave)
        guard let interval = interval,
              let nextPitch = MusicNotation.shared.intervalPitch(from: basePitch, in: interval) else {
            return [Pitch(keySignature.key.note, octave: octave)]
        }
        return [basePitch, nextPitch]
    }
    
    var body: some View {
        VStack {
            HStack {
                if isShowKeySignature {
                    KeySignatureView(keySignature: $keySignature, showStaff: true)
                }
                GroupNoteView(clef: keySignature.clef,
                              pitches: pitchGroup,
                              keySignature: keySignature,
                              isShowKeySignature: isShowKeySignature)
            }
            .overlay {
                VStack{
                    HStack {
                        ForEach(pitchGroup) { pitch in
                            Text(pitch.text)
                        }
                    }
                    if let interval = interval {
                        Text(interval.text)
                    }
                }
                .bold()
                .font(.caption)
                .offset(y: 80)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 200)
            List {
                Toggle("Show Key Signature", isOn: $isShowKeySignature)
                Group {
                    Picker("Clef", selection: $keySignature.clef) {
                        ForEach(ClefType.allCases) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    Picker("Style", selection: $intervalQuality) {
                        ForEach(intervalPosition.AvailableInterval) { style in
                            Text(style.abb)
                        }
                    }
                    Picker("Octave", selection: $octave) {
                        ForEach(keySignature.clef.preferenceOctaveRange, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                }
                .pickerStyle(.segmented)
                Picker("Series", selection: $intervalPosition) {
                    ForEach(IntervalPositionType.allCases) { type in
                        Text("\(type)")
                    }
                }
                CircleOfFifthsView(key: $keySignature.key, scale: $keySignature.scale)
                Button("Play", action: playInterval)
                    .disabled(isPlayingScale)
                    .buttonStyle(.accentButton)
            }
            .onChange(of: intervalPosition) {
                if !intervalPosition.AvailableInterval.contains(intervalQuality) {
                    intervalQuality = intervalPosition.reset
                }
            }
        }
    }
    
    private func playInterval() {
        isPlayingScale = true
        for pitch in pitchGroup {
            midi.play(pitch.MIDINote)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stopInterval()
        }
    }
    
    private func stopInterval() {
        for pitch in pitchGroup {
            midi.stop(pitch.MIDINote)
        }
        isPlayingScale = false
    }
}

#Preview {
    IntervalView()
}
