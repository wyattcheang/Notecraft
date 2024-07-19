//
//  ContentView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 31/01/2024.
//

import SwiftUI

struct MenuBarView: View {
    @State var midi = MIDIPlayer()
    var body: some View {
        TabView {
            TheoryView()
                .tabItem() {
                    Image(systemName:"book.pages")
                        .padding()
                    Text("Theory")
                }
                .environment(\.midi, midi)
            PitchView()
                .tabItem() {
                    Image(systemName:"tuningfork")
                    Text("Pitch")
                }
                .environment(\.midi, midi)
            SheetView()
                .tabItem() {
                    Image(systemName:"music.note.list")
                        .padding()
                    Text("Sheet")
                }
            ProfileView()
                .tabItem() {
                    Image(systemName:"gearshape")
                        .padding()
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MenuBarView()
}

