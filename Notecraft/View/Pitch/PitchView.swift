//
//  TunerView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/02/2024.
//

import SwiftUI

struct PitchView: View {
    var body: some View {
        VStack {
            TunerView()
            MetronomeView()
            KeyboardView()
        }
    }
}

#Preview {
    PitchView()
}
