//
//  NotecraftApp.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 31/01/2024.
//

import SwiftUI
import GoogleSignIn

@main
struct NotecraftApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
