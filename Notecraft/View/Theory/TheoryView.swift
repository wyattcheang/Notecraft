//
//  LearnView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 25/04/2024.
//

import SwiftUI

enum LearnTab: Hashable {
    case study
    case quiz
    case note
}

struct TabButtonAsset: Hashable {
    var tab: LearnTab
    var icon: String
    var text: String
}

struct TheoryView: View {
    @State private var currentTab: LearnTab = .quiz
    
    let chapters: [Chapter] = loadFile("chapter.json")

    private var assets: [TabButtonAsset] = [
        TabButtonAsset(tab: .study, icon: "book.fill", text: "Learn"),
        TabButtonAsset(tab: .quiz, icon: "pencil.line", text: "Quiz"),
        TabButtonAsset(tab: .note, icon: "bookmark.fill", text: "Bookmark")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TabButtonBar(assets: assets, selectedTab: $currentTab)
                    .padding(.horizontal)
                
                VStack {
                    switch currentTab {
                    case .study:
                        StudyView(chapters: chapters)
                    case .quiz:
                        QuizView(chapters: chapters)
                    case .note:
                        BookmarkView()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct TabButtonBar: View {
    var assets: [TabButtonAsset]
    @Binding var selectedTab: LearnTab
    
    var body: some View {
        HStack {
            ForEach(assets, id:\.tab) { asset in
                TabButton(icon:asset.icon,
                          text:asset.text,
                          tab: asset.tab,
                          selectedTab: $selectedTab)
            }
        }
    }
}

struct TabButton: View {
    var icon: String = ""
    var text: String = ""
    var tab: LearnTab
    
    @Binding var selectedTab: LearnTab
    var selected: Bool {
        return selectedTab == tab
    }
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    selectedTab = tab
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .padding(.horizontal, selected ? 0 : 10)
                    if selected {
                        Text(text)
                            .bold()
                        
                    }
                }
            }
            .padding()
            .frame(maxWidth: selected ? .infinity : .none, maxHeight: .infinity)
            .background(selected ? .accent : Color(UIColor.systemGray6))
            .foregroundColor(selected ? .white : .accent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .frame(height: 50)
    }
}

#Preview {
    TheoryView()
}

