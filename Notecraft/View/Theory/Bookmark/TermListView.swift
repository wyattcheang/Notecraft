//
//  TermView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 10/07/2024.
//

import Foundation
import SwiftUI

struct TermListView: View {
    let file: String
    @State private var termGroups: [TermGroup]
    @State private var selectedTerm: Term?
    @State private var showingPopover = false
    
    init(file: String) {
        self.file = file
        self.termGroups = loadFile(file)
    }
    
    var body: some View {
        List {
            ForEach(termGroups, id:\.self) { group in
                Section(group.section) {
                    ForEach(group.terms, id: \.self) { term in
                        NavigationLink(destination: PopoverView(term: term)) {
                            Text(term.name)
                        }
                    }
                }
                
            }
        }
        .popover(isPresented: $showingPopover) {
            if let term = selectedTerm {
                PopoverView(term: term)
            }
        }
    }
}

struct PopoverView: View {
    var term: Term
    
    var body: some View {
        VStack {
            VStack {
                if let bpm = term.bpm, !bpm.isEmpty {
                    BPMAnimationView(minBPM: bpm[0], maxBPM: bpm[1])
                        .padding()
                }
            }
            
            VStack {
                Text(term.name.capitalized)
                    .bold()
                    .font(.title)
                    .padding()
                
                HStack{
                    if let symbols = term.symbols {
                            ForEach(symbols, id:\.self) { hexcodes in
                                Text(" \(hexcodes.map { $0.toUnicode }.joined()) ")
                                    .notoMusicSymbolTextStyle()
                                    .padding(.vertical, -24)
                            }
                    }
                    
                    if let abb = term.abbreviation {
                        Text(abb.joined(separator: ", "))
                            .bold()
                            .font(.custom("TimesNewRomanPSMT", size: 24))
                    }
                }
                
                Text(term.meaning)
                    .padding()
                
                if let bpm = term.bpm, !bpm.isEmpty {
                    Text("\(bpm[0]) - \(bpm[1])")
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct BPMAnimationView: View {
    let minBPM: Int
    let maxBPM: Int
    @State private var ballPosition: CGFloat = -100
    @State private var moveRight = true
    
    var duration: Double {
        60.0 / Double((minBPM + maxBPM) / 2)
    }
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 50, height: 50)
                .offset(x: ballPosition, y: 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(200)) { // delay for 0.2 seconds
                        withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: true)) {
                            ballPosition = 100
                        }
                    }
                }
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    NavigationView {
        TermListView(file: "dynamic.json")
        TermListView(file: "tempo.json")
    }
    .navigationViewStyle(.stack)
}

#Preview("BPM") {
    BPMAnimationView(minBPM: 140, maxBPM: 150)
}

struct PreviewPopover: View {
    
    let text: [TermGroup] = loadFile("tempo.json")
    
    var body: some View {
        if let term = text.first?.terms.first {
            PopoverView(term: term)
        }
    }
}


#Preview("Popover") {
    PreviewPopover()
}
