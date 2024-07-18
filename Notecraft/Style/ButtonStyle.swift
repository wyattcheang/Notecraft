//
//  ButtonStyle.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 03/05/2024.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    var isFlash: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "pause.fill" : "play.fill")
                    .scaleEffect(configuration.isOn ? 1.2 : 1.0)
                    .animation(.easeInOut, value: configuration.isOn)
            }
            
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(isFlash ? .accent : Color(uiColor:.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(.easeInOut, value: isFlash)
    }
}

struct ToggleButtonStyle: ButtonStyle {
    var onColor: Color
    var offColor: Color
    
    init(onColor: Color = .primary, offColor: Color = .clear) {
        self.onColor = onColor
        self.offColor = offColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? onColor : offColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct BaseButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var fontColor: Color
    var backgroundColor: Color
    
    init(fontColor: Color = .primary, backgroundColor: Color = .clear) {
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(fontColor)
            .background(backgroundColor == .clear ? (colorScheme == .light ? Color.white : Color(uiColor: .systemGray4)) : backgroundColor)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct AccentButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        BaseButtonStyle(fontColor: .white,
                        backgroundColor: .accent)
        .makeBody(configuration: configuration)
    }
}

struct DefaultButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        BaseButtonStyle(fontColor: .black,
                        backgroundColor: .white)
        .makeBody(configuration: configuration)
    }
}

struct ConfirmButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    func makeBody(configuration: Configuration) -> some View {
        BaseButtonStyle()
        .makeBody(configuration: configuration)
    }
}

enum SelectType {
    case none
    case selected
    case correct
    case incorrect
    
    var color: Color {
        switch self {
        case .selected: return .secondary
        case .correct: return .green
        case .incorrect: return .red
        case .none: return .clear
        }
    }
}

struct QuizButtonStyle: ButtonStyle {
    var selectType: SelectType
    init(selectType: SelectType = .none) {
        self.selectType = selectType
    }
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        BaseButtonStyle(fontColor: .primary,
                        backgroundColor: colorScheme == .light ? Color(uiColor: .systemGray6) : Color(uiColor: .systemGray4))
        .makeBody(configuration: configuration)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(selectType.color, lineWidth: 2)
        )
    }
}

extension ButtonStyle where Self == DefaultButtonStyle {
    static var defaultButton: Self { Self() }
}

extension ButtonStyle where Self == AccentButtonStyle {
    static var accentButton: Self { Self() }
}

extension ButtonStyle where Self == QuizButtonStyle {
    static func quizButton(_ selectType: SelectType) -> Self {
        Self(selectType: selectType)
    }
}

struct Preview: View {
    var body: some View {
        VStack{
            Button("test", action: {})
                .buttonStyle(.quizButton(.correct))
                .shadow(radius: 5)
            Button("test", action: {})
                .buttonStyle(.quizButton(.incorrect))
                .shadow(radius: 5)
            Button("test", action: {})
                .buttonStyle(.quizButton(.selected))
                .shadow(radius: 5)
            Button("test", action: {})
                .buttonStyle(.quizButton(.none))
                .shadow(radius: 5)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
    }
}

#Preview {
    Preview()
        .preferredColorScheme(.dark)
}

