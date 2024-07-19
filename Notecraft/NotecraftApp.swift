//
//  NotecraftApp.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 31/01/2024.
//

import SwiftUI
import GoogleSignIn
import AVFAudio

@main
struct NotecraftApp: App {
    //    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    setupAudioSession()
                }
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session successfully set up.")
        } catch let error as NSError {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
