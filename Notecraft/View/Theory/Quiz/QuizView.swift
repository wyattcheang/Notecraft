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
                        HStack {
                            Text(chapter.title)
                            Spacer()
                            Text("\(chapter.id, specifier: "%02d")")
                        }
                        .bold()
                        .font(.headline)
                        Divider()
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
        HStack {
            Spacer()
            VStack {
                Circle()
                    .fill(isAvailable ? .accent : Color(uiColor: .systemGray4))
                    .frame(width: 90, height: 120)
                    .overlay {
                        Image("quiz_\(unit.id)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        Text(unit.title)
                            .font(.subheadline)
                            .offset(y: 60)
                    }
                    .onTapGesture {
                        if isAvailable {
                            isQuizStarted.toggle()
                        }
                    }
                    .fullScreenCover(isPresented: $isQuizStarted) {
                        LoadQuizView(unitId: unit.id, back: {
                            isQuizStarted.toggle()
                            reload()
                        })
                    }
            }
            if isAvailable {
                Group {
                    switch isLoading {
                    case true:
                        VStack(alignment: .leading) {
                            ForEach(0...4, id:\.self) {_ in
                                Text((Array(repeating: " ", count: 10).joined()))
                            }
                        }
                        .redacted(reason: .placeholder)
                        .shimmering()
                    case false:
                        if let bestResult = bestResult {
                            VStack(alignment: .leading) {
                                Text("Best Result")
                                    .bold()
                                Text("\(bestResult.date.formatted())")
                                Text("\((bestResult.accuracy * 100), specifier: "%.1f")%")
                                Text("\(bestResult.timeTaken.secondToString())")
                            }
                            .opacity(1)
                            .transition(.identity)
                        } else {
                            VStack {
                                Text("No Record")
                            }
                            .opacity(1)
                            .transition(.identity)
                        }
                    }
                }
                .padding()
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
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

#Preview {
    QuizView(chapters: loadFile("chapter.json"))
}

