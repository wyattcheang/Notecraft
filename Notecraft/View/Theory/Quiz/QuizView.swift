//
//  QuizView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 26/06/2024.
//

import SwiftUI

struct QuizView: View {
    let chapters: [Chapter]
    
    @State var quizzesAvailability: [QuizUnitAvailability] = []
    @State var isSelected: Bool = true
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(chapters) { chapter in
                    Section {
                        ForEach(chapter.units) { unit in
                            QuizIconView(unit: unit,
                                         isAvailable:checkAvailability(unit.id),
                                         reload: fetchQuizUnitAvailability)
                            .padding()
                        }
                    } header: {
                        SectionHeaderView(text: chapter.title, index: chapter.id)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchQuizUnitAvailability()
        }
    }
    
    func checkAvailability(_ unitId: Int) -> Bool {
        if let availability = quizzesAvailability.first(where: { $0.unitId == unitId })?.availability {
            return availability
        }
        return false
    }
    
    private func fetchQuizUnitAvailability() {
        Database.shared.fetchQuizUnitAvailability { result in
            switch result {
            case .success(let data):
                quizzesAvailability = data
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

struct QuizIconView: View {
    var unit: Unit
    var isAvailable: Bool
    var reload: () -> Void
    
    @State var isLoading: Bool = true
    @State var isQuizStarted: Bool = false {
        didSet {
            if !isQuizStarted {
                fetchBestQuizResult()
            }
        }
    }
    
    @State private var bestResult: QuizLog?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Button(action: { isQuizStarted.toggle() }) {
                    UnitIcon(unit: unit, image: "quiz_\(unit.id)", isDisabled: !isAvailable)
                }
                .disabled(!isAvailable)
                .fullScreenCover(isPresented: $isQuizStarted) {
                    LoadQuizView(unitId: unit.id, back: {
                        isQuizStarted.toggle()
                        reload()
                    })
                }
            }
            if isAvailable {
                QuizRecordView(isLoading: isLoading, result: bestResult)
            }
        }
        .onAppear {
            fetchBestQuizResult()
        }
        .onChange(of: isAvailable) {
            fetchBestQuizResult()
        }
    }
    
    private func fetchBestQuizResult() {
        isLoading = true
        if isAvailable {
            Database.shared.fetchBestQuizResult(unitId: unit.id) { result in
                switch result {
                case .success(let log):
                    withAnimation {
                        self.bestResult = log
                    }
                case .failure(_):
                    withAnimation {
                        self.bestResult = nil
                    }
                }
                withAnimation {
                    self.isLoading = false
                }
            }
        } else {
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct QuizRecordView: View {
    var isLoading: Bool
    var result: QuizLog?
    
    var body: some View {
        VStack {
            Group {
                switch isLoading {
                case true:
                    VStack(alignment: .leading) {
                        ForEach(0...4, id:\.self) {_ in
                            Text((Array(repeating: " ", count: 20).joined()))
                        }
                    }
                    .redacted(reason: .placeholder)
                    .shimmering()
                case false:
                    if let result = result {
                        VStack(alignment: .leading) {
                            Text("Best Result")
                                .bold()
                            Text("\(result.date.formatted())")
                            Text("\((result.accuracy * 100), specifier: "%.1f")%")
                            Text("\(result.timeTaken.secondToString())")
                        }
                        .transition(.identity)
                    } else {
                        VStack {
                            Text("No Record")
                        }
                        .transition(.identity)
                    }
                }
            }
            .padding()
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxHeight: 90)
    }
}


