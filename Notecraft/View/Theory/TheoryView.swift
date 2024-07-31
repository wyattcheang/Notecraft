//
//  LearnView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 25/04/2024.
//

import SwiftUI

enum TheoryTabBar: Hashable {
    case lesson
    case quiz
    case bookmark
}

struct TabButtonAsset: Hashable {
    var tab: TheoryTabBar
    var icon: String
    var text: String
}

struct TheoryView: View {
    @State private var currentTab: TheoryTabBar = .quiz
    @State private var allChapter: [Chapter] = []
    
    private var assets: [TabButtonAsset] = [
        TabButtonAsset(tab: .lesson, icon: "book.fill", text: "Lesson"),
        TabButtonAsset(tab: .quiz, icon: "pencil.line", text: "Quiz"),
        TabButtonAsset(tab: .bookmark, icon: "bookmark.fill", text: "Bookmark")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TabButtonBar(assets: assets, selectedTab: $currentTab)
                    .padding(.horizontal)
                
                VStack {
                    switch currentTab {
                    case .lesson:
                        LessonView(chapters: allChapter)
                    case .quiz:
                        QuizView(chapters: allChapter)
                    case .bookmark:
                        BookmarkView()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            fetchChapter()
        }
    }
    
    private func fetchChapter() {
        Database.shared.fetchChapter { result in
            switch result {
            case .success(let success):
                allChapter = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

struct TabButtonBar: View {
    var assets: [TabButtonAsset]
    @Binding var selectedTab: TheoryTabBar
    
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
    var tab: TheoryTabBar
    
    @Binding var selectedTab: TheoryTabBar
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

