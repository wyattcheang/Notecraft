//
//  SignUpView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/05/2024.
//
import SwiftUI
import Observation

enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

enum AuthFlow: String {
    case signIn = "Sign In"
    case signUp = "Sign Up"
    
    var reversed: AuthFlow {
        switch self {
        case .signIn:
                .signUp
        case .signUp:
                .signIn
        }
    }
}

@Observable
class FieldCredential {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var authFlow: AuthFlow = .signIn
    var showPassword: Bool = false
    var showConfirmPassowrd: Bool = false
    
    func reset() {
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
    }
    
    var isValid: Bool {
        authFlow == .signIn
        ? email.isValidEmail() && password.isValidPassword()
        : email.isValidEmail() && password.isValidPassword() && password == confirmPassword
    }
    
    func switchFlow() {
        authFlow = authFlow == .signIn ? .signUp : .signIn
    }
}

struct EmailFieldView: View {
    @Environment(\.user) var user: UserModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading: Bool = false
    @State private var isSecured: Bool = false
    @State private var alert = AlertControl()
    @State private var credential = FieldCredential()
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        VStack {
            HStack {
                Text(credential.authFlow == .signIn ?
                     "Welcome back!" : "Join Us!")
                .font(.largeTitle)
                .bold()
                Spacer()
            }
            .padding()
            
            FieldContainer {
                Image(systemName: "at")
                TextField("Email", text: $credential.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { onSubmit() }
            }
            
            FieldContainer {
                PasswordField(title: "Password",
                              text: $credential.password,
                              focusState: .password,
                              submitLabel: credential.authFlow == .signIn ? .go : .next,
                              onSubmit: onSubmit)
            }
            
            if credential.authFlow == .signUp {
                FieldContainer{
                    PasswordField(title: "Confirm password",
                                  text: $credential.confirmPassword,
                                  focusState: .confirmPassword,
                                  submitLabel: .go,
                                  onSubmit: onSubmit)
                }
            }
            
            if !user.errorMessage.isEmpty {
                VStack {
                    Text(user.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button {
                credential.authFlow == .signIn
                ? signInWithEmailPassword()
                : signUpWithEmailPassword()
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(credential.authFlow.rawValue)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!credential.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            HStack {
                Text(credential.authFlow == .signIn ?
                     "Don't have an account yet?" : "Already have an account?")
                Button(credential.authFlow.reversed.rawValue) {
                    withAnimation {
                        credential.switchFlow()
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $alert.isPresented) {
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text(alert.dismissMessage)))
        }
    }
    
    private func onSubmit() {
        if focus == .email {
            focus = .password
        } else if focus == .password {
            if credential.authFlow == .signIn && credential.isValid {
                handleAuth()
            } else if credential.authFlow == .signUp {
                focus = .confirmPassword
            }
        } else if focus == .confirmPassword && credential.isValid {
            handleAuth()
        }
    }
    
    private func signInWithEmailPassword() {
        Task {
            await user.signInWithEmailPassword(email: credential.email, password: credential.password) { result in
                switch result {
                case .success(_):
                    dismiss()
                case .failure(let error):
                    alert.title = "Sign In Failed"
                    alert.message = error.localizedDescription
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                }
            }
        }
    }
    
    private func signUpWithEmailPassword() {
        Task {
            await user.signUpWithEmailPassword(email: credential.email, password: credential.password) { result in
                switch result {
                case .success(_):
                    dismiss()
                case .failure(let error):
                    alert.title = "Sign Up Failed"
                    alert.message = error.localizedDescription
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                }
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        if credential.authFlow == .signIn {
            signInWithEmailPassword()
        } else {
            signUpWithEmailPassword()
        }
        isLoading = false
    }
}

struct PasswordField: View {
    @State var showPassword: Bool = false
    
    let title: String
    @Binding var text: String
    @FocusState private var focus: FocusableField?
    var focusState: FocusableField
    var submitLabel: SubmitLabel
    var onSubmit: () -> Void
    
    var body: some View {
        let Field: some View = showPassword
        ? AnyView(TextField("Password", text: $text))
        : AnyView(SecureField("Password", text: $text))
        
        HStack {
            Image(systemName: "lock")
            Field
                .textContentType(.password)
                .focused($focus, equals: focusState)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
            
            Toggle(isOn: $showPassword) {
                Image(systemName: showPassword ? "eye" : "eye.slash")
                    .padding(.horizontal, -4)
                    .padding(.vertical, 4)
            }
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .tint(.gray)
            .opacity(0.7)
            .contentTransition(.symbolEffect)
        }
    }
}

#Preview {
    EmailFieldView()
}
