//
//  NoteView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 25/06/2024.
//

import SwiftUI

#Preview {
    KeyTimeSignatureView()
}

struct NotationRenderView: View {
    var hexCodes: [String]
    private var unicodeString: String
    
    init(_ hexCodes: [String] = []) {
        self.hexCodes = hexCodes
        unicodeString = hexCodes.map { $0.toUnicode }.joined()
    }
    
    var body: some View {
        Text(" \(unicodeString) ")
    }
}

struct KeyTimeSignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    @State var keySignature: KeySignature = .init(clef: .treble, scale: .major, key: .C)
    @State var timeSignature: TimeSignature = .init(beat: 4, time: 4)
    @State var accidentalPreference: AccidentalType = .sharp
    
    var body: some View {
        VStack {
            ZStack {
                StaffView(5)
                HStack {
                    KeySignatureView(keySignature: $keySignature)
                    TimeSignatureView(timeSignature: $timeSignature)
                }
            }
            .padding()
            Text("\(keySignature.key.text) \(keySignature.scale.name) in \(keySignature.clef.rawValue.capitalized) Clef")
        }
        List {
            Group {
                Picker("Clef", selection: $keySignature.clef) {
                    ForEach(ClefType.allCases) { type in
                        Text(type.rawValue)
                    }
                }
                Picker("Scale", selection: $keySignature.scale) {
                    ForEach(ScaleType.basicCase) { type in
                        Text(type.name)
                    }
                }
                Picker("Accidental Preference", selection: $accidentalPreference) {
                    ForEach(AccidentalType.preference) { accidental in
                        Text(accidental.rawValue)
                    }
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Picker("Beat", selection: $timeSignature.beat) {
                    ForEach(1...12, id: \.self) { range in
                        Text("\(range)").tag(range)
                    }
                }
                Picker("Time", selection: $timeSignature.time) {
                    ForEach(1...12, id: \.self) { range in
                        Text("\(range)").tag(range)
                    }
                }
            }
            VStack {
                CircleOfFifthsView(scale: keySignature.scale, key: $keySignature.key)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
