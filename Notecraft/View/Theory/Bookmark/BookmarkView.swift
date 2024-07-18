//
//  BookmarkView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 10/07/2024.
//

import SwiftUI

struct BookmarkView: View {
    
    // Define a dictionary of titles and their corresponding destinations
    let items: [(title: String, destination: AnyView)] = [
            ("Signatures", AnyView(KeyTimeSignatureView())),
            ("Tempo", AnyView(TermListView(file: "tempo.json"))),
            ("Dynamic", AnyView(TermListView(file: "dynamic.json"))),
            ("Mood", AnyView(TermListView(file: "mood.json"))),
            ("Scale", AnyView(ScaleView())),
            ("Interval", AnyView(IntervalView()))
        ]
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(items, id: \.title) { item in
                NavigationLink(destination: item.destination) {
                    CardView(title: item.title)
                }
            }
            .padding()
        }
    }
}

struct CardView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
                .font(.title2)
            Spacer()
        }
        .padding()
        .padding(.vertical)
        .background(.accent)
        .foregroundColor(.white)
        .frame(maxHeight: 90)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .visualEffect { content, proxy in
            content
                .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 2))
        }
    }
}


#Preview {
    NavigationView {
        BookmarkView()
    }
    .navigationViewStyle(.stack)
}
