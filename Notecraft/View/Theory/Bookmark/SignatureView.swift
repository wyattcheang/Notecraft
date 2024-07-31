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


struct SignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    @State private var keySignature = KeySignature()
    @State private var timeSignature = TimeSignature()
    
    @State private var staffWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            StaffView(width: staffWidth)
            HStack {
                KeySignatureView(keySignature: $keySignature)
                TimeSignatureView(timeSignature: $timeSignature)
            }
            .padding(.horizontal)
            .widthAware($staffWidth)
        }
        .padding()
        Group {
            Text(keySignature.text)
            Text(timeSignature.meter.text)
        }
        .font(.headline)
        List {
            Picker("Beat", selection: $timeSignature.beat) {
                ForEach(1...12, id: \.self) { range in
                    Text("\(range)").tag(range)
                }
            }
            Picker("Subdivision", selection: $timeSignature.subdivision) {
                ForEach(timeSignature.availableSubdivision, id: \.self) { range in
                    Text("\(range)").tag(range)
                }
            }
            Picker("Clef", selection: $keySignature.clef) {
                ForEach(ClefType.allCases) { type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            VStack {
                CircleOfFifthsView(key: $keySignature.key, scale: $keySignature.scale)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Signatures")
        .navigationBarTitleDisplayMode(.inline)
    }
}
