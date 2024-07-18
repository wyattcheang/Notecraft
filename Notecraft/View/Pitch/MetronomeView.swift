//
//  Metronome.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import SwiftUI

struct MetronomeView: View {
    @State var metronome = MetronomeModel()
    @State var isStarted: Bool = false
    @State var height: CGFloat = 140
    
    var body: some View {
        HStack {
            MetronomePickerView(title: "BPM", range: 30...400, height: height, selection: $metronome.bpm)
            MetronomePickerView(title: "Beats", range: 1...12, height: height, selection: $metronome.beat)
            MetronomePickerView(title: "Division", range: 1...16, height: height, selection: $metronome.division)
            VStack {
                Toggle("Play", isOn: $isStarted)
                    .labelStyle(.iconOnly)
                    .toggleStyle(CheckToggleStyle(isFlash: metronome.onBeat))
                    .onChange(of: isStarted) { _, _ in
                        if isStarted {
                            metronome.startTick()
                        } else {
                            metronome.stopTick()
                        }
                    }
                Button(action: metronome.handleTap) {
                    Text("TAP")
                        .bold()
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(.rect(cornerRadius: 10.0))
                }
            }
            .frame(height: height)
        }
        .padding()
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemGray6))
        .clipShape(.rect(cornerRadius: 16.0))
        .shadow(radius: 4)
        .padding()
    }
    
    struct MetronomePickerView: View {
        var title: String
        var range: ClosedRange<Int>
        
        var height: CGFloat = 140
        @Binding var selection: Int
        
        var body: some View {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: height)
                .overlay {
                    Picker(title, selection: $selection) {
                        ForEach(range, id: \.self) { value in
                            Text("\(value)")
                                .bold()
                                .font(.headline)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .overlay {
                    Text(title)
                        .bold()
                        .font(.caption)
                        .offset(y: (height/2) + 12)
                }
        }
    }
}
