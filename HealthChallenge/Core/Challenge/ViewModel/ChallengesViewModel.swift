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

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadChallenges(for type: String) async {
        isLoading = true
        errorMessage = nil
        do {
            challenges = try await ChallengeManager.shared.getDailyChallenges().filter { challenge in
                switch type {
                case "Daily":
                    return challenge.isDaily
                case "Weekly":
                    return challenge.isWeekly
                case "Monthly":
                    return challenge.isMonthly
                default:
                    return challenge.isDaily || challenge.isWeekly || challenge.isMonthly
                }
            }
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
