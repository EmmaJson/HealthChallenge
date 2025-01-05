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
    var activeChallenges: [ActiveChallenge] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    let challengeManager = ChallengeManager.shared

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        Task {
            await self.loadChallenges(type: "Daily")
            await loadActiveChallenges()
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
    
    func joinChallenge(_ challenge: Challenge) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try await UserManager.shared.joinChallenge(userId: userId, challenge: challenge)
            print("Successfully joined challenge: \(challenge.title)")
            await fetchActiveChallenges()
        } catch {
            print("Failed to join challenge: \(error.localizedDescription)")
        }
    }
    
    func unjoinChallenge(_ challenge: Challenge) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try await UserManager.shared.unjoinChallenge(userId: userId, challengeId: challenge.id)
            print("Successfully unjoined challenge: \(challenge.title)")
            await fetchActiveChallenges()
        } catch {
            print("Failed to unjoin challenge: \(error.localizedDescription)")
        }
    }
    
    func fetchActiveChallenges() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            self.activeChallenges = user.activeChallenges ?? []
        } catch {
            print("Failed to fetch active challenges: \(error.localizedDescription)")
        }
    }
    
    func loadActiveChallenges() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            DispatchQueue.main.async {
                self.activeChallenges = user.activeChallenges ?? []
            }
        } catch {
            print("Failed to load active challenges: \(error.localizedDescription)")
        }
    }
    
    func isChallengeActive(_ challengeId: String) -> Bool {
        return activeChallenges.contains { $0.challengeId == challengeId }
    }
    
    
}
