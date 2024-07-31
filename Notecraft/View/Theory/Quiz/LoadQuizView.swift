//
//  QuizView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 28/05/2024.
//
import SwiftUI

enum LoadingStageType {
    case loading
    case done
    case null
    case failed
}

enum ButtonStageType: String {
    case none = "Select"
    case selected = "Confirm"
    case checked = "Next"
    
    var id: Self { self }
    mutating func next() {
        switch self {
        case .none: self = .selected
        case .selected: self = .checked
        case .checked: self = .none
        }
    }
}

struct LoadQuizView: View {
    let unitId: Int
    var back: () -> Void
    
    @State private var quizzes: [Quiz] = []
    @State private var loadingState: LoadingStageType = .loading
    
    @State private var answered: Int = 0 {
        didSet {
            if answered == quizzes.count {
                stopWatch.stop()
            }
        }
    }
    @State private var currentQuizIndex: Int = 0
    @State private var errorQuizIndices: [Int] = []
    
    @State private var stopWatch = StopWatchModel()
    
    private var progress: Double {
        Double(answered) / Double(quizzes.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch loadingState {
            case .loading:
                LoadingView()
            case .done:
                if currentQuizIndex < quizzes.count {
                    QuizProgressView(progress: progress, error: errorQuizIndices.count, back: back, time: stopWatch.formatTime)
                    ZStack {
                        ForEach(Array(zip(quizzes.indices, quizzes)), id: \.0) { index, quiz in
                            QuizContentView(quiz: quiz, next: nextQuiz, error: addErrorQuiz, answered: addAnsweredQuiz)
                                .zIndex(currentQuizIndex == index ? 1 : 0)
                        }
                        
                    }
                    .onAppear {
                        stopWatch.start()
                    }
                } else {
                    QuizCompletionView(unitId: unitId,
                                       error: errorQuizIndices.count,
                                       total: quizzes.count,
                                       timeTaken: stopWatch.time,
                                       restart: restart,
                                       back: back)
                }
            case .null:
                QuizNullView(back: back)
            case .failed:
                QuizNullView(back: back)
            }
        }
        .onAppear { fetchQuizzes() }
        .onDisappear {
            stopWatch.stop()
            quizzes = []
        }
    }
    
    func restart() {
        loadingState = .loading
        answered = 0
        currentQuizIndex = 0
        errorQuizIndices = []
        fetchQuizzes()
    }
    
    func nextQuiz() { currentQuizIndex = currentQuizIndex + 1 }
    
    func addAnsweredQuiz() { answered = answered + 1 }
    
    func addErrorQuiz() { errorQuizIndices.append(currentQuizIndex) }
    
    func fetchQuizzes() {
        Database.shared.fetchQuizzes(unitId: unitId) { result in
            switch result {
            case .success(let fetchedQuizzes):
                quizzes = fetchedQuizzes.shuffled()
                if !quizzes.isEmpty {
                    loadingState = .done
                } else {
                    loadingState = .null
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct QuizContentView: View {
    var quiz: Quiz
    var next: () -> Void
    var error: () -> Void
    var answered: () -> Void
    
    @Environment(\.midi) var midi: MIDIPlayer
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var stage: ButtonStageType = .none
    @State private var selectedOption: Option? = nil
    
    var isAnswerCorrect: Bool {
        return selectedOption?.correctness ?? true
    }
    
    private var columns: [GridItem]  {
        guard let image = quiz.options.first?.uiImage,
              image.size.width / image.size.height <= 1.8 else {
            return [GridItem(.flexible())]
        }
        return Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    func buttonActionHandler() {
        if stage == .checked { next() }
        stage.next()
        if stage == .checked {
            answered()
            if !isAnswerCorrect { error() }
        }
    }
    
    func buttonStyleHandler(option: Option) -> SelectType {
        switch stage {
        case .none, .selected:
            return selectedOption?.id == option.id ? .selected : .none
        case .checked:
            if option.correctness {
                return .correct
            } else if selectedOption?.id == option.id {
                return .incorrect
            } else {
                return .none
            }
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                let size = reader.size
                ScrollView(.vertical) {
                    VStack {
                        Text(quiz.question)
                            .font(.headline)
                            .padding(10)
                        if let image = quiz.uiImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width/2)
                                .background(.white)
                                .clipShape(.rect(cornerRadius: 16.0))
                                .padding()
                        }
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(quiz.options, id: \.id) { option in
                                Button(action: {
                                    selectedOption = option
                                    stage = .selected
                                }) {
                                    VStack {
                                        if let image = option.uiImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .background(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 16.0))
                                                .padding()
                                        }
                                        if option.answer != "" {
                                            Text(option.answer)
                                        }
                                    }
                                }
                                .buttonStyle(.quizButton(buttonStyleHandler(option: option)))
                                .disabled(stage == .checked)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(colorScheme == .dark ? .black : .white)
            
            HStack {
                Button("\(stage.rawValue)", action: buttonActionHandler)
                    .buttonStyle(BaseButtonStyle(fontColor: .white, backgroundColor: .accentColor))
                    .disabled(stage == .none)
                
                if !quiz.midi.isEmpty {
                    PlayMidiButton(isPlaying: midi.isPlaying,
                                   play: { midi.play(midiGroup: quiz.midi) },
                                   stop: midi.stopAll)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .frame(maxWidth: 500)
        .background(colorScheme == .dark ? .black : .white)
    }
}

#Preview("Completion") {
    QuizCompletionView()
}

enum ListItemValue {
    case string(String)
    case date(Date)
    case percentage(Double)
    case int(Int)
}

struct ListItem {
    var icon: String
    var text: String
    var value: ListItemValue
    var color: Color?
}

struct QuizCompletionView: View {
    @State private var loadingState: LoadingStageType = .loading
    @State var bestQuizResult: QuizLog?
    
    var unitId: Int = 1
    var error: Int = 3
    var total: Int = 10
    var timeTaken: Int = 0
    
    var restart: () -> Void = {}
    var back: () -> Void = {}
    
    var accuracy: Double {
        1 - (Double(error) / Double(total))
    }
    
    var isPassed: Bool {
        accuracy >= 80
    }
    
    var performanceData: [ListItem] {
        return [
            ListItem(icon: "list.clipboard", text: "Total Questions", value: .int(total), color: nil),
            ListItem(icon: "checkmark", text: "Correct Answers", value: .int(total - error), color: .green),
            ListItem(icon: "xmark", text: "Wrong Answers", value: .int(error), color: .red),
            ListItem(icon: "timer", text: "Time Taken", value: .string(timeTaken.secondToString()), color: nil)
        ]
    }
    
    var bestResultData: [ListItem] {
        guard let result = bestQuizResult else {
            return []
        }
        return [
            ListItem(icon: "calendar", text: "Date", value: .date(result.date), color: nil),
            ListItem(icon: "gauge", text: "Accuracy", value: .percentage(Double(result.accuracy)), color: nil),
            ListItem(icon: "timer", text: "Time Taken", value: .string(result.timeTaken.secondToString()), color: nil)
        ]
    }
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading, .null, .failed:
                LoadingView()
            case .done:
                VStack {
                    Spacer()
                    VStack {
                        Text("\((accuracy * 100), specifier: "%.1f")%")
                            .bold()
                            .font(.largeTitle)
                        Text("Quiz completed successfully!")
                    }
                    .padding()
                    
                    List {
                        Section(header: Text("Performance")) {
                            ForEach(performanceData, id: \.text) { item in
                                performanceRow(item: item)
                            }
                        }
                        Section(header: Text("Best Result")) {
                            ForEach(bestResultData, id: \.text) { item in
                                performanceRow(item: item)
                            }
                        }
                    }
                    
                    HStack {
                        Button("Try Again", action: restart)
                            .buttonStyle(BaseButtonStyle(backgroundColor: Color(uiColor: .systemGray5)))
                        Button(isPassed ? "Next" : "Back", action: back)
                            .buttonStyle(.accentButton)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: 500)
        .onAppear {
            addQuizLog()
        }
    }
        
    
    private func addQuizLog() {
        let quizLog = QuizLog(unitId: unitId,
                              accuracy: accuracy,
                              timeTaken: timeTaken)
        Database.shared.addQuizLog(quiz_log: quizLog) { result in
            switch result {
            case .success(_):
                fetchBestQuizResult()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func fetchBestQuizResult() {
        Database.shared.fetchBestQuizResult(unitId: unitId) { result in
            switch result {
            case .success(let log):
                bestQuizResult = log
                loadingState = .done
                print(loadingState)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func performanceRow(item: ListItem) -> some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(item.color ?? .primary)
            Text(item.text)
            Spacer()
            switch item.value {
            case .string(let value):
                Text(value)
            case .date(let value):
                Text(value.formatted())
            case .percentage(let value):
                Text("\((value * 100), specifier: "%.1f")%")
            case .int(let value):
                Text("\(value)")
            }
        }
    }
}

#Preview {
    QuizCompletionView()
}

struct QuizNullView: View {
    var back: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: back) {
                    Label("Back", systemImage: "chevron.left")
                }
                Spacer()
            }
            .padding()
            Spacer()
            Text("Currently no quizzes are available, try again later.")
                .padding()
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

struct QuizProgressView: View {
    var progress: Double
    var error: Int
    var back: () -> Void
    var time: String
    
    var body: some View {
        VStack {
            HStack {
                ProgressView(value: progress)
                    .animation(.easeInOut(duration: 16.0), value: progress)
            }
            .padding(.horizontal)
            HStack {
                Button("Back", systemImage: "chevron.left", action: back)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(time)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                HStack {
                    Text("\(error)")
                    Image(systemName: "xmark")
                }
                .foregroundColor(.red)
                .bold()
                .font(.callout)
                .opacity(error == 0 ? 0: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .animation(.bouncy, value: error)
            }
            .padding()
        }
    }
}

#Preview {
    LoadQuizView(unitId: 1, back: {})
}
