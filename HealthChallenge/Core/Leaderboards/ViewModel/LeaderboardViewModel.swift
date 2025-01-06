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
    
    let types = [LeaderBoard.points, LeaderBoard.calories, LeaderBoard.steps, LeaderBoard.distance]
    var currentType: Int = 0
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
                    self.showAlert = false //Ssssssssssssssssssss
                }
            }
        }
    }
    
    private func fecthLeaderboard() async throws -> LeaderboardResult {
        let leaders = try await LeaderboardManager.sharded.fetchLeaderboards()
        let top10: [LeaderboardUser]
        switch leaderboardtype {
        case .steps:
            Logger.log("Entered Steps")
            top10 = Array(leaders.sorted(by: { $0.steps > $1.steps }).prefix(8))
        case .calories:
            top10 = Array(leaders.sorted(by: { $0.calories > $1.calories }).prefix(8))
        case .distance:
            top10 = Array(leaders.sorted(by: { $0.distance > $1.distance }).prefix(8))
        case .points:
            top10 = Array(leaders.sorted(by: { $0.points > $1.points }).prefix(8))
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
            self.calories = try await fetchCurrentWeekCalories()
            self.distance = try await fetchCurrentWeekDistance()
            self.points = await fetchUserPoints()
        } catch {
            self.steps = 0
            self.calories = 0
            self.distance = 0
        }
        try await LeaderboardManager.sharded.postStepCountUpdateForUser(leader: LeaderboardUser(id: userId, username: username, calories: Int(calories), steps: Int(steps), distance: Int(distance), points: Int(points)))
    }
    
    func moveLeft() {
        if currentType > 0 {
            currentType -= 1
            leaderboardtype = types[currentType]
            updateLeaderboard(
            )
        }
    }
    
    func moveRight() {
        if currentType < 3 {
            currentType += 1
            leaderboardtype = types[currentType]
            updateLeaderboard()
        }
    }
    
    private func fetchCurrentWeekStepCount() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            HealthKitManager.shared.fetchCurrentWeekStepCount { result in
                switch result {
                case .success(let stepCount):
                    Logger.log("Fetched step count: \(stepCount)")
                    continuation.resume(returning: stepCount)
                case .failure(let error):
                    Logger.log("Failed to fetch step count: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchCurrentWeekCalories() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            HealthKitManager.shared.fetchCurrentWeekCalories { result in
                switch result {
                case .success(let caloriesBurned):
                    Logger.log("Fetched calories: \(caloriesBurned)")
                    continuation.resume(returning: caloriesBurned)
                case .failure(let error):
                    Logger.log("Failed to fetch calories: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchCurrentWeekDistance() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            HealthKitManager.shared.fetchCurrentWeekDistance { result in
                switch result {
                case .success(let distanceCovered):
                    Logger.log("Fetched distance: \(distanceCovered)")
                    continuation.resume(returning: distanceCovered)
                case .failure(let error):
                    Logger.log("Failed to fetch distance: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchUserPoints() async -> Double {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            let stats = try await UserManager.shared.getUserStats(userId: userId)
            return Double(stats.totalPoints)
        } catch {
            print("Failed to fetch user stats: \(error.localizedDescription)")
            return 0
        }
    }
}

