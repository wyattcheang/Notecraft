//
//  AuthenticationView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/05/2024.
//

import SwiftUI

struct AuthView: View {
    @Environment(\.user) var user: UserModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingEmailView = false
    @State private var buttonGroupHeight: CGFloat = 0
    @State private var animateGradient: Bool = false
    
    private func continueWithGoogle() async {
        Task {
            if try await user.continueWithGoogle() {
                dismiss()
            } else {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Notecraft")
                .foregroundStyle(.white)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("your music journey partner")
                .foregroundStyle(.white)
                .font(.caption)
                .fontWeight(.light)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    Task {
                        await continueWithGoogle()
                    }
                } label: {
                    HStack {
                        Image("google")
                        Text("Continue with Google")
                    }
                }
                Button(action: { isShowingEmailView.toggle() }) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Continue with Email")
                    }
                }
                .sheet(isPresented: $isShowingEmailView) {
                    EmailFieldView()
                        .padding()
                }
            }
            .buttonStyle(.defaultButton)
            .padding(24)
            .background {
                ZStack() {
                    Rectangle()
                        .clipShape(.rect(cornerRadii: .init(topLeading: 36.0, topTrailing: 36.0)))
                        .foregroundColor(.black)
                }
                .ignoresSafeArea(edges:.bottom)
            }
            .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(colors: [.start, .end], startPoint: .topTrailing, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .onAppear {
                    withAnimation {
                        animateGradient.toggle()
                    }
                }
            
        }
    }
    
}

#Preview {
    AuthView()
}
