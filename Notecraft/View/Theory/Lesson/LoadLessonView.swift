//
//  LessonView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 20/07/2024.
//
import SwiftUI

struct LoadLessonView: View {
    let unit: Unit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.midi) private var midi: MIDIPlayer
    @State private var lessons: [Lesson] = []
    @State private var currentLessonIndex: Int = 0
    @State private var loadingState: LoadingStageType = .loading
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                LoadingView()
            case .null, .failed:
                Text("Currently no lessons are available, try again later.")
                    .padding()
            case .done:
                VStack {
                    let lesson = lessons[currentLessonIndex]
                    ZStack {
                        ForEach(Array(zip(lessons.indices, lessons)), id: \.0) { index, lesson in
                            VStack{
                                if let image = lesson.uiImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .background(.white)
                                        .clipShape(.rect(cornerRadius: 16.0))
                                        .padding()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .zIndex(currentLessonIndex == index ? 1 : 0)
                        }
                    }
                    VStack {
                        VStack {
                            Text(.init(lessons[currentLessonIndex].text))
                                .transition(.slide)
                        }
                        .padding()
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGray6))
                        .clipShape(.rect(cornerRadius: 16.0))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    HStack {
                        Button("Previous", systemImage: "chevron.left", action: { handlePage(direction: .previous) } )
                            .disabled(currentLessonIndex == 0)
                        Spacer()
                        
                        if !lesson.midi.isEmpty {
                            VStack {
                                Button("Midi", systemImage: "play.fill", action: { midi.play(midiGroup: lesson.midi) })
                                    .disabled(midi.isPlaying)
                            }
                            Spacer()
                        }
                        Button("Next", systemImage: "chevron.right", action: { handlePage(direction: .next) } )
                            .disabled(currentLessonIndex == lessons.count - 1)
                    }
                    .buttonStyle(.circular())
                }
                .padding()
            }
        }
        .onAppear() {
            fetchLessons()
        }
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.accent)
                        .imageScale(.large)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(currentLessonIndex + 1)/\(lessons.count)")
            }
        }
    }
    
    private func handlePage(direction: FlipDirection) {
        switch direction {
        case .previous:
            if currentLessonIndex > 0 {
                withAnimation { currentLessonIndex -= 1 }
            } else {
                currentLessonIndex = 0
            }
        case .next:
            if currentLessonIndex < lessons.count - 1 {
                withAnimation { currentLessonIndex += 1 }
            } else {
                currentLessonIndex = lessons.count - 1
            }
        }
    }
    
    private func fetchLessons() {
        loadingState = .loading
        Database.shared.fetchLesson(unitId: unit.id) { result in
            switch result {
            case .success(let data):
                if !data.isEmpty {
                    self.lessons = data
                    self.loadingState = .done
                } else {
                    self.loadingState = .null
                }
            case .failure(_):
                self.loadingState = .failed
            }
        }
    }
}

struct LoadLessonPreview: View {
    let chapters: [Chapter] = loadFile("chapter.json")
    var unit: Unit?
    
    init() {
        if let unit = chapters.first?.units.first {
            self.unit = unit
        }
    }
    
    var body: some View {
        if let unit = unit {
            LoadLessonView(unit: unit)
        }
    }
}

#Preview {
    NavigationView {
        LoadLessonPreview()
    }
}
