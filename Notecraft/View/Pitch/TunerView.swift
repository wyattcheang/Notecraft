//
//  TunerView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import SwiftUI

struct TunerView: View {
    @State private var tuner = TunerModel()
    @AppStorage("pitchStandard") var pitchStandard: Double = 440.0
    @AppStorage("accidentalPreference") var accidentalPreference: AccidentalType = .sharp
    
    struct Config {
        var lowerBound: Int = -50
        var upperBound: Int = 50
        var interval: Int = 2
        var steps: Int = 10
        var spacing: CGFloat = 8
        var accurateLowerBound: Int = -10
        var accurateUpperBound: Int = 10
    }
    
    var config: Config = Config()
    var isAccurate: Bool {
        tuner.cent >= Double(config.accurateLowerBound) &&
        tuner.cent <= Double(config.accurateUpperBound)
    }
    
    var body: some View {
        VStack {
            frequencyAndCentView
            noteAndOctaveView
            tunerScaleView
        }
        .onAppear {
            tuner.setPrams(pitchStandard: pitchStandard, accidentalPreference: accidentalPreference)
            tuner.startTuning()
        }
        .onDisappear {
            tuner.stopTuning()
        }
    }
    
    private var frequencyAndCentView: some View {
        HStack {
            Text("\(tuner.frequency, specifier: "%.1f") Hz")
            Spacer()
            Text("\(tuner.cent, specifier: "%.1f") ¢")
        }
        .padding()
    }
    
    private var noteAndOctaveView: some View {
        HStack(spacing: -0.4) {
            if tuner.note.isEmpty {
                Text("--")
                    .font(.system(size: 72))
            } else {
                Text(tuner.note)
                    .font(.system(size: 72))
                VStack {
                    Text(tuner.accidental.symbol)
                        .font(.system(size: 56))
                        .opacity(tuner.accidental == .natural ? 0 : 100)
                        .padding(.bottom, -36)
                    Text("\(tuner.octave)")
                        .font(.system(size: 36))
                }
            }
        }
        .fontWeight(.heavy)
        .padding()
    }
    
    private var tunerScaleView: some View {
        VStack {
            ZStack {
                scaleMarkers
                accuracyIndicator
                centIndicator
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var scaleMarkers: some View {
        HStack(spacing: config.spacing) {
            ForEach(Array(stride(from: config.lowerBound, through: config.upperBound, by: config.interval)), id: \.self) { index in
                let remainder = index % config.steps
                Divider()
                    .background(remainder == 0 ? Color.primary : .gray)
                    .frame(width: 0, height: remainder == 0 ? 25 : 20)
                    .overlay(alignment: .bottom) {
                        if remainder == 0 {
                            Text("\(index)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fixedSize()
                                .offset(y: 25)
                        }
                    }
                    .opacity((index < config.accurateLowerBound || index > config.accurateUpperBound) ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var accuracyIndicator: some View {
        RoundedRectangle(cornerRadius: 8.0)
            .fill(isAccurate ? Color.green : Color.clear)
            .stroke(isAccurate ? Color.green : Color.gray, lineWidth: 1)
            .frame(width: config.spacing * CGFloat(config.accurateUpperBound), height: 35)
    }
    
    private var centIndicator: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 2, height: isAccurate ? 30 : 40)
            .offset(x: tuner.cent / Double(config.interval) * config.spacing)
            .animation(.spring(), value: tuner.cent)
    }
}
