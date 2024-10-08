//
//  CircleOfFifthsView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 14/07/2024.
//

import SwiftUI

struct CircleOfFifthsView: View {
    @Binding var key: KeyType
    @Binding var scale: ScaleType
    @State private var accidental: AccidentalType = .sharp
    
    var keys: [KeyType] {
        switch (scale, accidental) {
        case (.major, .sharp): return KeyType.circleOfFifthMajorSharp
        case (.major, .flat): return KeyType.circleOfFifthMajorFlat
        case (.minor, .sharp): return KeyType.circleOfFifthMinorSharp
        case (.minor, .flat): return KeyType.circleOfFifthMinorFlat
        case (_, _): return []
        }
    }
    
    var size: Double = 160
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                ZStack {
                    ForEach(Array(zip(keys.indices, keys)), id: \.0) { index, key in
                        let startAngle = Double(index) * 30 - 105
                        let endAngle = Double(index + 1) * 30 - 105
                        let middleAngle = (startAngle + endAngle) / 2
                        let isSelected = self.key == key
                        let color = isSelected ? .accent : Color(uiColor:(.systemGray4))
                        ArcSegment(startDegree: startAngle, endDegree: endAngle)
                            .fill(color)
                            .scaleEffect(isSelected ? 1 : 0.95)
                            .animation(.linear, value: isSelected)
                            .overlay(
                                Text(key.text)
                                    .bold()
                                    .font(.subheadline)
                                    .position(position(for: middleAngle, in: size/2))
                            )
                            .frame(width: size, height: size)
                            .onTapGesture {
                                self.key = key
                            }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                HStack {
                    Circle()
                        .fill(Color(uiColor: .systemGray5))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(scale == .major ? "M" : "m")
                        }
                        .onTapGesture(perform: toggleScale)
                    Spacer()
                    Circle()
                        .fill(Color(uiColor: .systemGray5))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(accidental.symbol)
                        }
                        .onTapGesture(perform: toggleAccidental)
                }
                .bold()
                .font(.subheadline)
            }
        }
        .padding(.vertical)
    }
    
    private func toggleScale() {
        if scale == .major {
            self.scale = .minor(.natural)
        } else if scale == .minor(.natural) {
            self.scale = .major
        }
    }
    
    private func toggleAccidental() {
        if accidental == .sharp {
            self.accidental = .flat
        } else if accidental == .flat {
            self.accidental = .sharp
        }
    }
    
    private func position(for angle: Double, in radius: Double) -> CGPoint {
        let length = radius + 20
        let radians = angle * .pi / 180
        let x = length * cos(radians) + radius
        let y = length * sin(radians) + radius
        return CGPoint(x: x, y: y)
    }
}


struct ArcSegment: Shape {
    var startDegree: Double
    var endDegree: Double
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: startDegree),
                    endAngle: Angle(degrees: endDegree),
                    clockwise: clockwise)
        path.closeSubpath()
        return path
    }
}

#Preview {
    CircleOfFifthsView(key: .constant(.C), scale: .constant(.major))
}
