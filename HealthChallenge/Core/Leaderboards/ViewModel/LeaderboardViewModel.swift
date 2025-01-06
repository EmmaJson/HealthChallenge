//
//  LeaderboardViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import Foundation

enum LeaderBoard: String {
    case steps = "Steps"
    case calories = "Calories"
    case distance = "Distance"
    case points = "Points"
    
    var id: String { rawValue }
}

@Observable
class LeaderboardViewModel {
    var showAlert = false
    var title = "Leaderboard"
    var leaderboardtype = LeaderBoard.points
    
    var steps = 0.0
    var calories = 0.0
    var distance = 0.0
    var points = 0.0
    
    var leaderResult = LeaderboardResult(user: nil, top10: [])
    
    var mockData = [
        LeaderboardUser(id: "test1", username: "Test 1", calories: 12032, steps: 70531, distance: 634, points: 20),
    ]
    
    struct LeaderboardResult {
        let user: LeaderboardUser?
        let top10: [LeaderboardUser]
    }
    
    func updateLeaderboard() {
        Task {
            do {
                try await postStepCountUpdateForUser()
                let result = try await fecthLeaderboard()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert = false
                    self.leaderResult = result
                }
                Logger.log("Updating leaderboard")
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
        let top10: [LeaderboardUser]
        switch leaderboardtype {
        case .steps:
            top10 = Array(leaders.sorted(by: { $0.steps > $1.steps }).prefix(10))
        case .calories:
            top10 = Array(leaders.sorted(by: { $0.calories > $1.calories }).prefix(10))
        case .distance:
            top10 = Array(leaders.sorted(by: { $0.distance > $1.distance }).prefix(10))
        case .points:
            top10 = Array(leaders.sorted(by: { $0.points > $1.points }).prefix(10))
        }
        
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
        guard !userId.isEmpty else {
            throw LeaderBoardViewModelError.unableTooFetchLoggedInUserId
        }
    
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            throw LeaderBoardViewModelError.unableToFetchUsername
        }
        do {
            self.steps =  try await fetchCurrentWeekStepCount()
            self.calories = 0
            self.distance = 0
            self.points = 0
        } catch {
            self.steps = 0
            self.calories = 0
            self.distance = 0
            self.points = 0
        }
        try await LeaderboardManager.sharded.postStepCountUpdateForUser(leader: LeaderboardUser(id: userId, username: username, calories: Int(calories), steps: Int(steps), distance: Int(distance), points: Int(points)))
        
        // MARK: Add mockdata for leaderboard
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
