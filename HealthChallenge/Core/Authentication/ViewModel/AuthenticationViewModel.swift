//
//  AuthenticationViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import Foundation
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    private let profileVm = ProfileViewModel()
    
    @Published var email: String = ""
    @Published var password: String = ""

    @Published var authProviders: [AuthProviderOptions] = []
    @Published var authUser: AuthDataResultModel? = nil

    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
}

// MARK: LINK ACCOUNT
extension AuthenticationViewModel {
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkEmailAccount() async throws {
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}

// MARK: SIGN IN EMAIL
extension AuthenticationViewModel {
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            throw URLError(.badServerResponse)
        }
        try await AuthenticationManager.shared.signIn(email: email, password: password)
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            throw URLError(.badServerResponse)
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DbUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func resetPassword() async throws {
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword() async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func updateEmail() async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
}

// MARK: SIGN IN SSO

extension AuthenticationViewModel {
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DbUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}

// MARK: SIGN IN ANONYMOUS
extension AuthenticationViewModel {
    
    func signInAnonymous() async throws {
        print("Signing in anonymous / VM")
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DbUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}
