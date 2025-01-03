//
//  ProfileViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DbUser? = nil
    @Published var username: String = ""

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavouriteChallenge() {
        guard let user else { return }
        let challenge = Challenge(id: "1", title: "Hike 10", description: "Walk 10 kilometers", points: 10, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date())
        Task {
            try await UserManager.shared.addFavouriteChallenge(userId: user.userId, challenge: challenge)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavouriteChallenge() {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeFavouriteChallenge(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}
