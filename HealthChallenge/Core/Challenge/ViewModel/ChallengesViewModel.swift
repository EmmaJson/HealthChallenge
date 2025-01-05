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
    var groupedChallenges: [String: [Challenge]] {
        Dictionary(grouping: challenges, by: { $0.interval }) // Assuming `Challenge` has an `interval` property
    }
    var activeChallenges: [ActiveChallenge] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    let challengeManager = ChallengeManager.shared

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        Task {
            await self.loadChallenges()
            await fetchActiveChallenges()
        }
    }

    func loadChallenges() async {
        isLoading = true
        errorMessage = nil
        do {
            challenges.removeAll()
            let intervals = ["Daily", "Weekly", "Monthly"]
            for interval in intervals {
                let loadedChallenges = try await ChallengeManager.shared.getChallenges(interval: interval)
                challenges.append(contentsOf: loadedChallenges)
            }
        } catch {
            errorMessage = "Failed to load challenges: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func joinChallenge(_ challenge: Challenge) async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            try await UserManager.shared.joinChallenge(userId: userId, challenge: challenge)
            print("Successfully joined challenge: \(challenge.title)")
            await fetchActiveChallenges()
        } catch {
            print("Failed to join challenge: \(error.localizedDescription)")
        }
    }
    
    func unjoinChallenge(_ challenge: Challenge) async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            try await UserManager.shared.unjoinChallenge(userId: userId, challengeId: challenge.id)
            print("Successfully unjoined challenge: \(challenge.title)")
            await fetchActiveChallenges()
        } catch {
            print("Failed to unjoin challenge: \(error.localizedDescription)")
        }
    }
    
    func fetchActiveChallenges() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            self.activeChallenges = user.activeChallenges ?? []
        } catch {
            print("Failed to fetch active challenges: \(error.localizedDescription)")
        }
    }
    
    func isChallengeActive(_ challengeId: String) -> Bool {
        return activeChallenges.contains { $0.challengeId == challengeId }
    }
    
}
