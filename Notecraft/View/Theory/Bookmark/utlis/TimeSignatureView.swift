//
//  TimeSignatureView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 24/06/2024.
//

import SwiftUI

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

@Observable
class TimeSignature {
    var beat: Int = 4
    private var _subdivision: Int = 4
    
    var availableSubdivision = [2, 4, 8, 12, 16]
        
    var subdivision: Int {
        get {
            return _subdivision
        }
        set {
            if availableSubdivision.contains(newValue) {
                _subdivision = newValue
            }
        }
    }
    
    func setSubdivision(_ value: Int) {
        if availableSubdivision.contains(value) {
            self.subdivision = value
        }
    }
    
    var meter: Meter {
        switch (beat, subdivision) {
        case (2, 2), (2, 4), (2, 8), (3, 2), (3, 4), (3, 8), (4, 2), (4, 4), (4, 8):
            return .simple(beatType)
        case (6, 4), (6, 8), (6, 16), (9, 4), (9, 8), (9, 16), (12, 4), (12, 8), (12, 16):
            return .compound(beatType)
        default:
            return .odd
        }
    }
    
    var beatType: Meter.BeatMeasurement {
            switch (beat, subdivision) {
            case (2, _):
                return .duple
            case (3, _):
                return .triple
            case (4, _):
                return .quadruple
            case (6, _):
                return .duple
            case (9, _):
                return .triple
            case (12, _):
                return .quadruple
            default:
                return .irregular
            }
        }
}

struct TimeSignatureView: View {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    @Binding var timeSignature: TimeSignature
    
    private var spacing: CGFloat {
        return notationSize.CGFloatValue / 4
    }

    var body: some View {
        ZStack {
            NotationRenderView(getNumberReturnCode(value: String(timeSignature.beat)))
                .offset(y:-spacing)
            NotationRenderView(getNumberReturnCode(value: String(timeSignature.subdivision)))
                .offset(y:spacing)
        }
        .bravuraMusicSymbolTextStyle()
        .padding(.vertical, -50)
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
