//
//  ScaleView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 13/07/2024.
//

import SwiftUI

struct ScaleView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    @Environment(\.midi) var midi: MIDIPlayer
    
    @State var keySignature = KeySignature()
    @State var octave: Int = 4
    
    @State private var staffWidth: CGFloat = 0
    @State private var scaleOrder: ScaleOrderType = .both
    
    @State private var isShowingKeySignature: Bool = true
    
    private var pitchSet: [Pitch] {
        MusicNotation.shared.generateScale(from: keySignature.scale, in: keySignature.key, octave: octave, order: scaleOrder)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    StaffView(width: staffWidth)
                    HStack {
                        KeySignatureView(keySignature: $keySignature, showKeySignature: isShowingKeySignature)
                        ForEach(pitchSet.indices, id: \.self) { index in
                            let pitch = pitchSet[index]
                            Button(action: {
                                playNote(pitch: pitch)
                            }) {
                                NoteView(clef: keySignature.clef, pitch: pitch, isShowingKeySignature: isShowingKeySignature, keySignature: keySignature)
                            }
                            .id(index)
                            .overlay {
                                Text(pitch.text)
                                    .bold()
                                    .font(.caption)
                                    .offset(y: 80)
                            }
                        }
                    }
                    .frame(maxHeight: 280)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.5)
                    .widthAware($staffWidth)
                }
                .padding()
            }
            .overlay(alignment: .bottom) {
                HStack {
                    CircleToggleButton("music.note", toggle: $isShowingKeySignature)
                    Spacer()
                    Text(keySignature.textWithScaleType)
                        .font(.headline)
                    Spacer()
                    PlayMidiButton(isPlaying: midi.isPlaying, play: playScale, stop: midi.stopAll)
                }
                .padding(.horizontal)
            }
            .onAppear {
                proxy.scrollTo(midi.currentPlayingIndex, anchor: .center)
            }
            .onDisappear {
                midi.stopAll()
            }
            .onChange(of: midi.isPlaying) {
                if midi.isPlaying {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(midi.currentPlayingIndex, anchor: .center)
                    }
                }
            }
            .onChange(of: midi.currentPlayingIndex) {
                withAnimation(.easeInOut) {
                    proxy.scrollTo(midi.currentPlayingIndex, anchor: .center)
                }
            }
        }
        List {
            Group {
                Picker("Octave", selection: $octave) {
                    ForEach(keySignature.clef.preferenceOctaveRange, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                Picker("Clef", selection: $keySignature.clef) {
                    ForEach(ClefType.allCases) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                Picker("Order", selection: $scaleOrder) {
                    ForEach(ScaleOrderType.allCases) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                if keySignature.scale != .major {
                    Picker("Scale Style", selection: $keySignature.scale) {
                        ForEach(ScaleType.MinorScaleType.allCases) { type in
                            Text(type.rawValue.capitalized).tag(ScaleType.minor(type))
                        }
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            CircleOfFifthsView(key: $keySignature.key, scale: $keySignature.scale)
        }
        .navigationTitle("Scale")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: keySignature.clef) {
            if !keySignature.clef.preferenceOctaveRange.contains(octave) {
                self.octave = keySignature.clef.defaultOctave
            }
        }
    }
    
    private func playNote(pitch: Pitch) {
        midi.play(pitch.MIDINote)
    }
    
    private func stopNote(pitch: Pitch) {
        midi.stop(pitch.MIDINote)
    }
    
    private func playScale() {
        let midiGroup = pitchSet.map { Midi(notes: [$0.MIDINote]) }
        midi.play(midiGroup: midiGroup)
    }
}

#Preview {
    ScaleView()
}
