//
//  KeyboardView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import SwiftUI

struct KeyboardView: View {
    @AppStorage("isSustain") var isSustain: Bool = true
    var octaves: ClosedRange<Int> = 2...6
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(octaves, id:\.self) { octave in
                        OctaveView(octave: octave)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .overlay(alignment: .bottomTrailing) {
                Toggle("Sustain", isOn: $isSustain)
                    .bold()
                    .toggleStyle(.button)
                    .padding(.horizontal)
            }
        }
    }
}

struct OctaveView: View {
    @AppStorage("accidentalPreference") var accidentalPreference: AccidentalType = .sharp
    var octave: Int
    var blackKeys: [[FullNoteType]] {
        if accidentalPreference == .sharp {
            [[.CSharp, .DSharp], [.FSharp, .GSharp, .ASharp]]
        } else {
            [[.DFlat, .EFlat], [.GFlat, .AFlat, .BFlat]]
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            GroupKey(octave: octave, whiteKey: [.C, .D, .E], blackKey: blackKeys.first ?? [])
            GroupKey(octave: octave, whiteKey: [.F, .G, .A, .B], blackKey: blackKeys.last ?? [])
        }
    }
    
    struct GroupKey: View {
        var octave: Int
        var whiteKey: [FullNoteType]
        var blackKey: [FullNoteType]
        
        var body: some View {
            ZStack(alignment: .top) {
                HStack(spacing: 4) {
                    ForEach(whiteKey, id:\.self) { key in
                        let pitch = Pitch(key.note, octave: octave)
                        PianoKey(pitch: pitch)
                    }
                }
                
                HStack(spacing: 4){
                    ForEach(blackKey, id:\.self) { key in
                        let pitch = Pitch(key.note, octave: octave)
                        PianoKey(pitch: pitch)
                            .padding(.horizontal, 2)
                    }
                }
            }
            
        }
    }
    
    struct PianoKey: View {
        let pitch: Pitch
        
        @AppStorage("isSustain") var isSustain: Bool = true
        @Environment(\.midi) var midi: MIDIPlayer
        @State private var isLongPressed = false
        private let width: CGFloat = 44
        private var isWhiteKey: Bool {
            return pitch.note.accidental == .natural
        }
        
        var body: some View {
            let dragGesture = DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isLongPressed {
                        isLongPressed = true
                        midi.play(pitch.MIDINote)
                    }
                }
                .onEnded { _ in
                    isLongPressed = false
                    if !isSustain {
                        midi.stop(pitch.MIDINote)
                    }
                }
            
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 10, bottomTrailing: 10, topTrailing: 0))
                .fill(isWhiteKey ? Color.white : Color.black)
                .frame(width: isWhiteKey ? width : width - 2,
                       height: isWhiteKey ? width * 3.8 : (width - 2) * 2.6)
                .shadow(radius: 8)
                .scaleEffect(isLongPressed ? 0.95 : 1.0)
                .brightness(isLongPressed ? -0.05 : 0)
                .overlay {
                    VStack {
                        Spacer()
                        Text(pitch.note.baseNote == .C && pitch.note.accidental == .natural ? pitch.text : pitch.note.text)
                            .padding(.vertical)
                            .bold()
                            .font(.caption)
                            .foregroundColor(isWhiteKey ? .black : .white)
                    }
                }
                .gesture(dragGesture)
                .onDisappear {
                    midi.stop(pitch.MIDINote)
                }
        }
    }
}

struct KeyboardPreview: View {
    @State var midi = MIDIPlayer()
    var body: some View {
        KeyboardView()
            .environment(\.midi, midi)
            .onAppear {
                AudioSessionManager.shared.setCategory(.playback)
            }
    }
}

#Preview {
    KeyboardPreview()
}
