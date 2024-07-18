

import SwiftUI

struct ClefSignatureView: View {
    @State var keySignature: KeySignature = KeySignature()
    @State var timeSignature: TimeSignature = TimeSignature()
    
    private var keys: [KeyType] {
        switch keySignature.scale {
        case .major:
            return [.C, .G, .D, .A, .E, .B, .Fsharp, .Csharp, .F, .Bflat, .Eflat, .Aflat, .Dflat, .Gflat, .Cflat]
        case .minor:
            return [.A, .E, .B, .Fsharp, .Csharp, .Gsharp, .Dsharp, .Asharp, .D, .G, .C, .F, .Bflat, .Eflat, .Aflat]
        }
    }
    
    var body: some View {
        
        VStack {
            VStack {
                ZStack {
                    StaffView(5)
                    HStack {
                        KeySignatureView(keySignature: $keySignature)
                        TimeSignatureView(timeSignature: $timeSignature)
                    }
                }
                .padding()
                Text("\(keySignature.key.text) \(keySignature.scale.name)")
                if (timeSignature.complexity == .irregular &&
                    timeSignature.beatType == .irregular) {
                    Text("Irregular")
                } else {
                    Text("\(timeSignature.complexity.rawValue.capitalized) \(timeSignature.beatType.rawValue.capitalized)")
                }
            }
            .padding()
            VStack {
                List {
                    Picker("Scale", selection: $keySignature.scale) {
                        ForEach(ScaleType.basicCase) { scale in
                            Text(scale.name)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Clef", selection: $keySignature.clef) {
                        ForEach(ClefType.allCases) { clef in
                            Text(clef.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Key", selection: $keySignature.key) {
                        ForEach(keys) { key in
                            Text(key.text)
                        }
                    }
                    Picker("Beat", selection: $timeSignature.beat) {
                        ForEach(1...16, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // or any other picker style you prefer
                    Picker("Time", selection: $timeSignature.time) {
                        ForEach(1...16, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // or any other picker style you prefer
                }
            }
        }
        Spacer()
    }
}



#Preview {
    ClefSignatureView()
}
