//
//  MainView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/05/2024.
//

import SwiftUI

struct MainView: View {
    @State private var user = UserModel()
    var body: some View {
        Group {
            switch user.authState {
            case .unauthenticated:
                AuthView()
                    .environment(\.user, user)
            case .authenticating:
                LoadingView()
            case .authenticated:
                MenuBarView()
                    .environment(\.user, user)
            }
        }
        .task {
            await user.getCurrentSession()
            await listenToAuthStateChanges()
        }
    }

    private func listenToAuthStateChanges() async {
        print("listenToAuthStateCalled")
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                DispatchQueue.main.async {
                    if state.session != nil {
                        user.authState = .authenticated
                    } else {
                        user.authState = .unauthenticated
                    }
                }
            }
        }
    }
}

private struct UserModelKey: EnvironmentKey {
    static var defaultValue: UserModel = UserModel()
}

private struct TunerModelKey: EnvironmentKey {
    static var defaultValue: TunerModel = TunerModel()
}

private struct MidiPlayerKey: EnvironmentKey {
    static var defaultValue: MIDIPlayer = MIDIPlayer()
}

extension EnvironmentValues {
    var user: UserModel {
        get { self[UserModelKey.self] }
        set { self[UserModelKey.self] = newValue }
    }
    
    var tuner: TunerModel {
        get { self[TunerModelKey.self] }
        set { self[TunerModelKey.self] = newValue }
    }
    
    var midi: MIDIPlayer {
        get { self[MidiPlayerKey.self] }
        set { self[MidiPlayerKey.self] = newValue }
    }
}

