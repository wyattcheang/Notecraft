//
//  NoteView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 20/06/2024.
//

import SwiftUI

struct DictView: View {
    var symbols: [Symbol]
    var symbolsByCategory: [String: [Symbol]]
    init() {
        symbols = loadFile("symbol.json")
        self.symbolsByCategory = Dictionary(grouping: symbols, by: { $0.category })
    }
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(symbolsByCategory.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(symbolsByCategory[category] ?? [], id: \.unicode) { symbol in
                            HStack {
                                Text(" \(symbol.unicode.toUnicode) ")
                                    .notoMusicSymbolTextStyle()
                                Spacer()
                                Text(symbol.name)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Symbols by Category")
        }
    }
}

#Preview {
    DictView()
}

extension String {
    var dropHexPrefix: String {
        return self.replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "U+", with: "")
            .replacingOccurrences(of: "#", with: "")
    }
    
    var toUnicode: String {
        if let charCode = UInt32(self.dropHexPrefix, radix: 16),
           let unicode = UnicodeScalar(charCode) {
            let str = String(unicode)
            return str
        }
        return "error"
    }
}
