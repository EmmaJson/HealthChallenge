//
//  LeaderboardViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import Foundation

@Observable
class LeaderboardViewModel {
    var showAlert = false
    
    var leaderResult = LeaderboardResult(user: nil, top10: [])
    var mockData = [
        LeaderboardUser(id: "1",  username: "Emma", count: 2342),
        LeaderboardUser(id: "2",  username: "Lova", count: 2342),
        LeaderboardUser(id: "3",  username: "Julia", count: 2342),
        LeaderboardUser(id: "4",  username: "Julia2", count: 2342),
        LeaderboardUser(id: "5",  username: "Lova2", count: 2342),
        LeaderboardUser(id: "6",  username: "Emma2", count: 2342),
        LeaderboardUser(id: "7",  username: "Julia3", count: 2342),
        LeaderboardUser(id: "8",  username: "Lova3", count: 2342),
        LeaderboardUser(id: "9",  username: "Emma3", count: 2342),
        LeaderboardUser(id: "10", username: "Emma4", count: 2342),
    ]
    
    struct LeaderboardResult {
        let user: LeaderboardUser?
        let top10: [LeaderboardUser]
    }
    
    init() {
        updateLeaderboard()
    }
    
    func updateLeaderboard() {
        Task {
            do {
                try await postStepCountUpdateForUser()
                let result = try await fecthLeaderboard()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.leaderResult = result
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert = true
                }
            }
        }
    }
    
    private func fecthLeaderboard() async throws -> LeaderboardResult {
        let leaders = try await LeaderboardManager.sharded.fetchLeaderboards()
        let top10 = Array(leaders.sorted(by: { $0.count > $1.count }).prefix(10))
        let username = UserDefaults.standard.string(forKey: "username")

        if !top10.contains(where: { $0.username == username }) {
            let user = leaders.first(where: { $0.username == username })
            return LeaderboardResult(user: user, top10: top10)
        } else {
            return LeaderboardResult(user: nil, top10: top10)
        }
    }

    enum LeaderBoardViewModelError: Error {
        case unableToFetchUsername
        case unableTooFetchLoggedInUserId
    }
    
    private func postStepCountUpdateForUser() async throws {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            throw LeaderBoardViewModelError.unableToFetchUsername
        }
        let steps =  try await fetchCurrentWeekStepCount()
        try await LeaderboardManager.sharded.postStepCountUpdateForUser(leader: LeaderboardUser(id: userId, username: username, count: Int(steps)))
        //try await LeaderboardManager.sharded.postStepCountUpdateForUser(leader: LeaderboardUser(id: "t8xV64HGDuNuWN9SMsb0TsXh5kk1", username: "Lova", count: Int(12323)))
        //try await LeaderboardManager.sharded.postStepCountUpdateForUser(leader: LeaderboardUser(id: "YYKEJE5AMCND575bHLJN80L95yg1", username: "Julia", count: Int(9345)))
    }
    
    private func fetchCurrentWeekStepCount() async throws -> Double {
        try await withCheckedThrowingContinuation({ continuation in
            HealthKitManager.shared.fetchCurrentWeekStepCount { result in
                continuation.resume(with: result)
            }
        })
    }
}
