//
//  StudyView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/06/2024.
//

import Foundation
import SwiftUI

struct StudyView: View {
    let chapters: [Chapter]
 
    var body: some View {
        ScrollView(.vertical) {
            ForEach(chapters) { chapter in
                NavigationLink(destination: StudyCardView(chapter: chapter)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(chapter.title)
                                .font(.title2)
                                .bold()
                        }
                        .foregroundColor(.white)
                        Spacer()
                        Image("chapter_\(chapter.id)")
                    }
                    .padding()
                    .padding(.vertical)
                    .background(.accent)
                    .frame(maxHeight: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .visualEffect { content, proxy in
                        content
                            .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 2))
                    }
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
            Text(chapter.title)
                .font(.largeTitle)
                .bold()
            // Additional details about the lesson can be added here
        }
        .padding()
        .navigationTitle(chapter.title)
    }
}

#Preview {
    StudyView(chapters: loadFile("chapter.json"))
}
