//
//  SignInGoogle.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/05/2024.
//

import UIKit
import CryptoKit
import GoogleSignIn

struct SignInGoogleResult {
    let idToken: String
    let accessToken: String
}

@MainActor
class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
        
    }
    
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
          print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let user = signInResult?.user, let idToken = user.idToken else {
                completion(.failure(NSError()))
                print(error ?? "no error")
                return
            }
            let accessToken = user.accessToken.tokenString
            completion(.success(.init(idToken: idToken.tokenString, accessToken: accessToken)))
            }
    }
}
