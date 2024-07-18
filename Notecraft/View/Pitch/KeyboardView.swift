//
//  KeyboardView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import SwiftUI

struct KeyboardView: View {
    var octaves: ClosedRange<Int> = 2...6
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(octaves, id:\.self) { octave in
                    OctaveView(octave: octave)
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
    }
}

struct OctaveView: View {
    var octave: Int
    
    var body: some View {
        HStack(spacing: 4) {
            GroupKey(octave: octave, whiteKey: [.C, .D, .E])
            GroupKey(octave: octave, whiteKey: [.F, .G, .A, .B])
        }
    }
    
    struct GroupKey: View {
        @AppStorage("accidentalPreference") var accidentalPreference: AccidentalType = .sharp
        var octave: Int
        var accidental: AccidentalType = .flat
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
                        PianoKey(key: key, octave: octave, isWhite: true)
                    }
                }
                
                HStack(spacing: 4){
                    ForEach(blackKey, id:\.self) { key in
                        PianoKey(key: key, octave: octave, isWhite: false)
                            .padding(.horizontal, 2)
                    }
                }
            }
            
        }
    }
    
    struct PianoKey: View {
        let midi = MIDIPlayer.shared
        @GestureState var isLongPressed = false
        
        var key: FullNoteType
        var octave: Int
        var isWhite: Bool
        var width: CGFloat = 44
        var longPressGesture: some Gesture {
            LongPressGesture(minimumDuration: 0.1)
                .updating($isLongPressed) { currentState, gestureState, transaction in
                    gestureState = currentState
                }
        }
        var pitch: Pitch {
            return Pitch(key.note, octave: octave)
        }
        
        var body: some View {
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 10, bottomTrailing: 10, topTrailing: 0))
                .fill(isWhite ? Color.white : Color.black)
                .frame(width: isWhite ? width : width - 2,
                       height: isWhite ? width * 3.8 : (width - 2) * 2.6)
                .shadow(radius: 8)
                .scaleEffect(isLongPressed ? 0.95 : 1.0)
                .brightness(isLongPressed ? -0.05 : 0)
                .overlay {
                    VStack {
                        Spacer()
                        Text(key.rawValue == "C" ? "\(key.rawValue)\(octave)" : key.rawValue)
                            .padding(.vertical)
                            .bold()
                            .font(.caption)
                            .foregroundColor(isWhite ? .black : .white)
                    }
                }
                .gesture(longPressGesture)
                .onChange(of: isLongPressed) { pressed, _ in
                    if pressed {
                        midi.play(pitch.MIDINote)
                    } else {
                        midi.play(pitch.MIDINote)
                    }
                }
        }
    }
}

#Preview {
    KeyboardView()
}
