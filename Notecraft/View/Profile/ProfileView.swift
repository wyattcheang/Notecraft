//
//  ProfileView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/02/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.user) var user: UserModel
    @Environment(\.dismiss) var dismiss
    
    @State private var displayName: String = ""
    @State private var presentingConfirmationDialog = false
    @State private var showSignOutAlert = false
    
    private func signOut() async -> Bool {
        return await user.signOut()
    }
    @AppStorage("accidentalPreference") var accidentalPreference: AccidentalType = .sharp
    @AppStorage("pitchStandard") var pitchStandard: Double = 440.0
    @AppStorage("notationSize") var notationSize: NotationSize = .standard
    
    private var pitchRange: [Double] {
        Array(stride(from: 400.0, through: 480.0, by: 1.0))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Text("Email")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(user.data?.email ?? "")
                    }
                }
                Section("Preferences") {
                    Picker("Pitch Standard", selection: $pitchStandard) {
                        ForEach(pitchRange, id: \.self) { pitch in
                            Text("\(Int(pitch)) Hz").tag(pitch)
                        }
                    }
                    .pickerStyle(.automatic)
                    .foregroundStyle(.secondary)
                    HStack {
                        Text("Accidental")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("Accidental", selection: $accidentalPreference) {
                            ForEach(AccidentalType.preference) { accidental in
                                Text(accidental.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text("Notation Size")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("Notation Size", selection: $notationSize) {
                            ForEach(NotationSize.allCases) { size in
                                Text(size.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                Section {
                    Button("Sign Out", role: .cancel) {
                        Task {
                            showSignOutAlert = await signOut()
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .alert("You have successfully sign out",
                           isPresented: $showSignOutAlert) {
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                                isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
                //            Button("Delete Account", role: .destructive, action: deleteAccount)
                Button("Cancel", role: .cancel, action: { })
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(UserModel())
}
