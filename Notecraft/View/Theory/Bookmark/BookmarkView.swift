//
//  BookmarkView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 10/07/2024.
//

import SwiftUI

struct BookmarkItem {
    let title: String
    let image: Image
    let destination: AnyView
}

struct BookmarkView: View {
    let dictionaryItems: [BookmarkItem] = [
        BookmarkItem(title: "Tempo", image: Image("tempo"), destination: AnyView(TermListView(file: "tempo.json"))),
        BookmarkItem(title: "Dynamics", image: Image("dynamic"), destination: AnyView(TermListView(file: "dynamic.json"))),
        BookmarkItem(title: "Moods", image: Image("mood"), destination: AnyView(TermListView(file: "mood.json")))
    ]
    
    let experienceItems: [BookmarkItem] = [
        BookmarkItem(title: "Signatures", image: Image("signatures"), destination: AnyView(SignatureView())),
        BookmarkItem(title: "Scale", image: Image("scale"), destination: AnyView(ScaleView())),
        BookmarkItem(title: "Interval", image: Image("interval"), destination: AnyView(IntervalView()))
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                BookmarkSectionView(title: "Dictionary", items: dictionaryItems)
                BookmarkSectionView(title: "Experience", items: experienceItems)
            }
            .padding()
        }
    }
}

struct BookmarkSectionView: View {
    let title: String
    let items: [BookmarkItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(text: title)
            ForEach(items, id: \.title) { item in
                NavigationLink(destination: item.destination) {
                    CardView(title: item.title, image: item.image)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BookmarkView()
    }
    .navigationViewStyle(.stack)
}
