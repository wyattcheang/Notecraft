//
//  StudyView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/06/2024.
//

import Foundation
import SwiftUI

struct LessonView: View {
    let chapters: [Chapter]
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(chapters) { chapter in
                NavigationLink(destination: StudyCardView(chapter: chapter)) {
                    CardView(title: chapter.title, subtitle: chapter.subtitle, image: Image("chapter_\(chapter.id)"))
                }
            }
            .padding()
        }
    }
}

struct StudyCardView: View {
    var chapter: Chapter
    
    var body: some View {
        VStack {
            ForEach(chapter.units) { unit in
                NavigationLink(destination: LoadLessonView(unit: unit)) {
                    UnitIcon(unit: unit, image: "quiz_\(unit.id)")
                        .navigationTitle(chapter.title)
                        .padding(.vertical)
                }
            }
        }
        
    }
}
