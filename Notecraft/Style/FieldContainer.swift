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

struct WidthAwareModifier: ViewModifier {
    @Binding var width: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            width = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) {
                            width = geometry.size.width
                        }
                }
            )
    }
}

extension View {
    func widthAware(_ width: Binding<CGFloat>) -> some View {
        self.modifier(WidthAwareModifier(width: width))
    }
}
