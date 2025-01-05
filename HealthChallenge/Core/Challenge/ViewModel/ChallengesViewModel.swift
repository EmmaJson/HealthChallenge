//
//  ChallengesViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import Foundation
import FirebaseAuth

@MainActor
@Observable
final class ChallengesViewModel {
    var challenges: [Challenge] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    let challengeManager = ChallengeManager.shared

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        Task {
            await self.loadChallenges(type: "Daily")
        }
    }

    func loadChallenges(type: String) async {
        isLoading = true
        errorMessage = nil
        do {
            challenges = try await ChallengeManager.shared.getChallenges(interval: "Daily")
        } catch {
            errorMessage = "Failed to load challenges: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func signUp(for challenge: Challenge) async {
        guard let userId = currentUserId else {
            errorMessage = "No user logged in."
            return
        }
        do {
            try await ChallengeManager.shared.completeChallenge(userId: userId, challengeId: challenge.id)
        } catch {
            errorMessage = "Failed to sign up for challenge: \(error.localizedDescription)"
        }
    }
}
