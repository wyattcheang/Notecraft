//
//  SwiftUIView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 21/07/2024.
//

import SwiftUI
import WebKit
import UIKit
import ImageIO

struct SwiftUIView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct LoadingView: View {
    let text: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            VStack {
                GifImageView("loading")
                    .frame(maxWidth: 200, maxHeight: 200)
                Text(text)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct UnitIcon: View {
    var unit: Unit
    var image: String
    var isDisabled: Bool = false
    
    private var paddingBottom: CGFloat {
        max(10, CGFloat(unit.title.count) * 1.5)
    }
    
    var body: some View {
        VStack {
            Circle()
                .fill(isDisabled ? Color(uiColor: .systemGray4): .accent)
                .shadow(radius: isDisabled ? 2 : 6)
                .frame(width: 90, height: 90)
                .overlay {
                    Image("quiz_\(unit.id)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .foregroundColor(.white)
                }
            VStack {
                Text(unit.title)
                    .font(.subheadline)
            }
        }
    }
}

struct SectionHeaderView: View {
    let text: String
    var index: Int?
    
    var body: some View {
        HStack {
            Text(text.capitalized)
            Spacer()
            if let index = index {
                Text("\(index, specifier: "%02d")")
            }
        }
        .bold()
        .font(.headline)
        Divider()
    }
}

struct CircleToggleButton: View {
    let systemImage: String
    @Binding var toggle: Bool
    
    init(_ systemImage: String, toggle: Binding<Bool>) {
        self.systemImage = systemImage
        self._toggle = toggle
    }
    
    var body: some View {
        Toggle("Show Key Signature", isOn: $toggle)
            .font(.subheadline)
            .toggleStyle(CircleToggleStyle(onIcon: "music.note"))
    }
}

struct PlayMidiButton: View {
    let isPlaying: Bool
    let play: () -> Void
    let stop: () -> Void
    
    var body: some View {
        Button(isPlaying ? "Stop" : "Play",
               systemImage: isPlaying ? "stop.fill" : "play.fill") {
            if isPlaying { stop() }
            else { play() }
        }
               .font(.subheadline)
               .buttonStyle(.circular)
    }
}

struct CardView: View {
    let title: String
    var subtitle: String?
    var image: Image?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.title2)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            Spacer()
            if let image = image {
                image
            }
        }
        .padding()
        .padding(.vertical)
        .background(.accent)
        .foregroundColor(.white)
        .frame(maxHeight: 90)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .visualEffect { content, proxy in
            content
                .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 2))
        }
        .shadow(radius: 10)
    }
}

#Preview {
    LoadingView()
}


struct GifImageView: UIViewRepresentable {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        if let gifImage = UIImage.gif(name: name) {
            imageView.image = gifImage
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: container.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            if let gifImage = UIImage.gif(name: name) {
                imageView.image = gifImage
            }
        }
    }
}
