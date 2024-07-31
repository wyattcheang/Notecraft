//
//  Interval.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 14/07/2024.
//

import SwiftUI

struct IntervalView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    @Environment(\.midi) var midi: MIDIPlayer
    
    @State private var keySignature = KeySignature(key: .Csharp)
    @State private var intervalQuality: IntervalQualityType = .major
    @State private var intervalGeneric: IntervalGenericType = .third
    
    @State private var staffWidth: CGFloat = 0
    @State private var octave: Int = 4
    @State private var isShowingKeySignature: Bool = true

    
    var interval: Interval? {
        guard let interval = Interval(quality: intervalQuality, generic: intervalGeneric) else { return nil }
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
            ZStack {
                StaffView(width: staffWidth + 20)
                HStack {
                    KeySignatureView(keySignature: $keySignature, showKeySignature: isShowingKeySignature)
                    GroupNoteView(clef: keySignature.clef,
                                  pitches: pitchGroup,
                                  keySignature: keySignature,
                                  isShowingKeySignature: isShowingKeySignature)
                }
                .widthAware($staffWidth)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 230)
            .overlay(alignment: .bottom) {
                HStack {
                    CircleToggleButton("music.note", toggle: $isShowingKeySignature)
                    Spacer()
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
                    .font(.headline)
                    Spacer()
                    PlayMidiButton(isPlaying: midi.isPlaying, play: playInterval, stop: midi.stopAll)
                }
                .padding(.horizontal)
            }
            List {
                Picker("Generic", selection: $intervalGeneric) {
                    ForEach(IntervalGenericType.allCases) { type in
                        Text(type.ordinal)
                    }
                }
                .pickerStyle(.segmented)
                Picker("Quality", selection: $intervalQuality) {
                    ForEach(intervalGeneric.availableQualities) { style in
                        Text(style.abb)
                    }
                }
                .pickerStyle(.segmented)
                Picker("Octave", selection: $octave) {
                    ForEach(keySignature.clef.preferenceOctaveRange, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                .pickerStyle(.segmented)
                Picker("Clef", selection: $keySignature.clef) {
                    ForEach(ClefType.allCases) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                CircleOfFifthsView(key: $keySignature.key, scale: $keySignature.scale)
            }
            .onChange(of: intervalGeneric) {
                // to constrait a valid interval can be selected
                if !intervalGeneric.availableQualities.contains(intervalQuality) {
                    intervalQuality = intervalGeneric.defaultQuality
                }
            }
            .onChange(of: keySignature.clef) {
                if !keySignature.clef.preferenceOctaveRange.contains(octave) {
                    self.octave = keySignature.clef.defaultOctave
                }
            }
        }
        .navigationTitle("Interval")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func playInterval() {
        let interval = pitchGroup.map { $0.MIDINote }
        var midiGroup = pitchGroup.map { Midi(notes: [$0.MIDINote]) }
        midiGroup.append(Midi(notes: interval))
        
        midi.play(midiGroup: midiGroup)
    }
}

#Preview {
    IntervalView()
}
