//
//  FieldContainer.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 02/05/2024.
//

import SwiftUI

struct FieldContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
        }
        .bold()
        .frame(minHeight: 50)
        .background(Divider(), alignment: .bottom)
    }
}
