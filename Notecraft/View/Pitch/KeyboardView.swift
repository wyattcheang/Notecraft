//
//  KeyboardView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import SwiftUI

struct KeyboardView: View {
    @State private var isSuitain = true
    var octaves: ClosedRange<Int> = 2...6
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(octaves, id:\.self) { octave in
                    OctaveView(octave: octave, isSuitain: isSuitain)
                }
            }
            .padding(.bottom, 20)
            Toggle("Sustain", isOn: $isSuitain)
                .bold()
                .toggleStyle(.button)
        }
    }
}

struct OctaveView: View {
    var octave: Int
    var isSuitain: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            GroupKey(octave: octave, isSuitain: isSuitain, whiteKey: [.C, .D, .E])
            GroupKey(octave: octave, isSuitain: isSuitain, whiteKey: [.F, .G, .A, .B])
        }
    }
    
    struct GroupKey: View {
        @AppStorage("accidentalPreference") var accidentalPreference: AccidentalType = .sharp
        var octave: Int
        let isSuitain: Bool
        var whiteKey: [FullNoteType]
        var blackKey: [FullNoteType] {
            switch accidentalPreference {
            case .sharp, .natural, .doubleSharp:
                return whiteKey.dropLast().map { $0.sharp }
            case .flat, .doubleFlat:
                return whiteKey.dropFirst().map { $0.flat }
            }
        }
        
        var body: some View {
            ZStack(alignment: .top) {
                HStack(spacing: 4) {
                    ForEach(whiteKey, id:\.self) { key in
                        let pitch = Pitch(key.note, octave: octave)
                        PianoKey(pitch: pitch, isSuitain: isSuitain)
                    }
                }
                
                HStack(spacing: 4){
                    ForEach(blackKey, id:\.self) { key in
                        let pitch = Pitch(key.note, octave: octave)
                        PianoKey(pitch: pitch, isSuitain: isSuitain)
                            .padding(.horizontal, 2)
                    }
                }
            }
            
        }
    }
    
    struct PianoKey: View {
        let pitch: Pitch
        let isSuitain: Bool
        
        @State private var isLongPressed = false
        @Environment(\.midi) var midi: MIDIPlayer
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
                    if !isSuitain {
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
