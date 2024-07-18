//
//  TimeSignatureView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 24/06/2024.
//

import SwiftUI

@Observable
class TimeSignature {
    var beat: Int
    var time: Int
    
    init(beat: Int = 4, time: Int = 4) {
        self.beat = beat
        self.time = time
    }
    
    var complexity: TimeSignComplexity {
        if (beat == 2 || beat == 3 || beat == 4) && (time == 2 || time == 4 || time == 8) {
            return .simple
        }
        if (beat == 6 || beat == 9 || beat == 12) && (time == 4 || time == 8 || time == 16) {
            return .compound
        }
        else {
            return .irregular
        }
    }
    
    var beatType: TimeSignBeat {
        switch (beat, time) {
        case (2, _):
            return .duple
        case (3, _):
            return .triple
        case (4, _):
            return .quadruple
        case (6, 8), (6, 16):
            return .duple
        case (9, 8), (9, 16):
            return .triple
        case (12, 8), (12, 16):
            return .quadruple
        default:
            return .irregular
        }
    }
}

struct TimeSignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    @Binding var timeSignature: TimeSignature
    var showStaff: Bool = false
    
    private var spacing: CGFloat {
        return notationSize.CGFloatValue / 4
    }

    var body: some View {
        ZStack {
            if showStaff {
                StaffView(1)
                    .notoMusicSymbolTextStyle()
            }
            Group {
                NotationRenderView(getNumberReturnCode(value: String(timeSignature.beat)))
                    .padding(.top, -spacing)
                    .padding(.bottom, spacing)
                NotationRenderView(getNumberReturnCode(value: String(timeSignature.time)))
                    .padding(.top, spacing)
                    .padding(.bottom, -spacing)
            }
            .bravuraMusicSymbolTextStyle()
            .padding(.vertical, -50)
        }
    }
}

func getNumberReturnCode(value: String) -> [String] {
    let dict: [Int: String] = [
        0: "E080",
        1: "E081",
        2: "E082",
        3: "E083",
        4: "E084",
        5: "E085",
        6: "E086",
        7: "E087",
        8: "E088",
        9: "E089",
    ]
    
    var hexCodes: [String] = []
    
    for char in value {
        if let number = Int(String(char)), let hexCode = dict[number] {
            hexCodes.append(hexCode)
        }
    }
    return hexCodes == [] ? ["E084"] : hexCodes
}

#Preview {
    TimeSignatureView(timeSignature: .constant(TimeSignature()))
}
