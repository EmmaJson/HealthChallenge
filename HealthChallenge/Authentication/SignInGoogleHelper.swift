//
//  SignInGoogleHelper.swift
//  HealthChallenge
//
//  Created by Emma Johanssonon 2024-12-29.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String
}

final class SignInGoogleHelper {
    
    @MainActor
    func signIn() async throws  -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let name = gidSignInResult.user.profile?.name ?? ""
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name)
        return tokens
    }
}
