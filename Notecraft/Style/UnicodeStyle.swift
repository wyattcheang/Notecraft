//
//  UnicodeStyle.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 22/06/2024.
//

import Foundation
import SwiftUI

struct UnicodeStyle: ViewModifier {
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    let fontName: String
    func body(content: Content) -> some View {
        content
            .font(.custom(fontName, size: notationSize.CGFloatValue))
    }
}

extension View {
    func notoMusicSymbolTextStyle() -> some View {
        self.modifier(UnicodeStyle(fontName: "NotoMusic-Regular"))
    }
    
    func bravuraMusicSymbolTextStyle() -> some View {
        self.modifier(UnicodeStyle(fontName: "Bravura"))
    }
}
