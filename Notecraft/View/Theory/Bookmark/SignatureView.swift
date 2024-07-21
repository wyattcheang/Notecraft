//
//  NoteView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 25/06/2024.
//

import SwiftUI

#Preview {
    SignatureView()
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

struct SignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    @State var keySignature: KeySignature = .init(clef: .treble, scale: .major, key: .C)
    @State var timeSignature: TimeSignature = .init(beat: 4, time: 4)
    
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
            .frame(maxWidth: .infinity)
            Group {
                Picker("Clef", selection: $keySignature.clef) {
                    ForEach(ClefType.allCases) { type in
                        Text(type.rawValue)
                    }
                }
            }
            .pickerStyle(.segmented)
            VStack {
                CircleOfFifthsView(key: $keySignature.key, scale: $keySignature.scale)
            }
        }
    }
}
