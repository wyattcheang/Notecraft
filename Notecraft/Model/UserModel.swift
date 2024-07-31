//
//  AuthModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 30/04/2024.
//

import Foundation
import Supabase
import GoogleSignIn
import GoogleSignInSwift

enum AuthState {
    case unauthenticated
    case authenticating
    case authenticated
}

@Observable
class UserModel {
    // Variables
    @MainActor
    var uuidString: String = ""
    var data: User?
    var authState: AuthState
    var errorMessage: String
    var sheetDirectory: URL?
    
    init() {
        self.authState = .authenticating
        self.errorMessage = ""
    }
    
    private func wait() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

// GET, DELETE, SIGNOUT
extension UserModel {
    @MainActor
    func getCurrentSession() async {
        do {
            let session = try await supabase.auth.session
            self.data = session.user
            if let uuidString = data?.id.uuidString {
                self.uuidString = uuidString
                createUserSheetDirectory()
            }
        } catch {
            return
        }
    }
    
    func signOut() async -> Bool {
        authState = .authenticating
        do {
            try await supabase.auth.signOut()
            DispatchQueue.main.async {
                self.authState = .unauthenticated
                self.data = nil
            }
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            DispatchQueue.main.async {
                self.authState = .unauthenticated
            }
            return false
        }
    }
}

// MARK: - Email and Password Authentication
extension UserModel {
    
    @MainActor
    func signInWithEmailPassword(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) async {
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            data = session.user
            completion(.success(true))
            authState = .authenticated
        }
        catch  {
            completion(.failure(error))
            authState = .unauthenticated
        }
    }
    
    @MainActor
    func signUpWithEmailPassword(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) async {
        do {
            let session = try await supabase.auth.signUp(email: email, password: password)
            data = session.user
            completion(.success(true))
            authState = .authenticated
        }
        catch  {
            completion(.failure(error))
            authState = .unauthenticated
        }
    }
}

// MARK: - Google Authentication
extension UserModel {
    @MainActor
    func continueWithGoogle() async throws -> Bool {
        let google = SignInGoogle()
        do {
            let result = try await google.startSignInWithGoogleFlow()
            try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .google, idToken: result.idToken, accessToken: result.accessToken))
            await getCurrentSession()
            return true
        }
        catch {
            return false
        }
    }
}


extension UserModel {
    @MainActor
    static var preview: UserModel {
        let model = UserModel()
        let user = User(id: UUID(),
                        appMetadata:[:],
                        userMetadata:[:],
                        aud: "",
                        email: "test@mail.com", 
                        createdAt: Date(),
                        updatedAt: Date())
        model.data = user
        return model
    }
}

extension UserModel {
    @MainActor func createUserSheetDirectory() {
        guard let userId = self._data?.id.uuidString else {
            return
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directory = documentsURL.appendingPathComponent("\(userId)/sheets")
        // Check if 'sheets' directory exists, create if it doesn't
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                print("called2")
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                print("Created 'Sheets' directory at: \(directory)")
                sheetDirectory = directory
            } catch {
                print("Failed to create 'Sheets' directory: \(error.localizedDescription)")
            }
        } else {
            sheetDirectory = directory
            print(self.uuidString)
        }
    }
}
