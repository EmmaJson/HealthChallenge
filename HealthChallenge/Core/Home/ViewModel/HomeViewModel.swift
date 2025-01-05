//
//  HomeViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
    let healthManager = HealthKitManager.shared
    
    var calories: Int = 0
    var steps: Int = 0
    var distance: Int = 0
    var distanceString: String = ""
    var activities = [ActivityCard]()
    private var activeChallenges = [ActiveChallenge]()
    var challenges = [ChallengeCard]()
    var completedChallenges = [PastChallenge]()
    
    
    var currentCalorieGoal: Double = 0
    var currentStepGoal: Double = 0
    var currentDistanceGoal: Double = 0
    
    var calorieGoal: Double = 0
    var stepGoal: Double = 0
    var distanceGoal: Double = 0
    
    var showEditGoal: Bool = false
    
    private let activityOrder = ["Calories", "Steps", "Distance", "Heart Rate", "Active", "Caloric Intake"]
    
    init() {
        Logger.info("Initializing HomeViewModel")
        DispatchQueue.main.async {
            self.authorizeAndFetchData()
        }
        Task {
            await self.fetchGoals()
            await checkExpiredChallenges()
            await self.fetchCompletedChallenges()
            await self.fetchActiveChallenges()
            await self.refreshChallenges()
        }
        startDailyUpdate()
    }
    
    /// Authorizes HealthKit and fetches data if successful
    private func authorizeAndFetchData() {
        Logger.info("Authorizing HealthKit and fetching data")
        healthManager.authorizeHealthKit { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let authorized):
                    if authorized {
                        Logger.success("HealthKit authorization successful. Fetching data...")
                        self.refreshData()
                    } else {
                        Logger.error("HealthKit authorization denied.")
                    }
                case .failure(let error):
                    Logger.error("HealthKit authorization failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Refreshes all activity data
    func refreshData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.activities.removeAll()
        }
        fetchTodayCalories()
        fetchTodaySteps()
        fetchTodayDistance()
        fetchTodayCalorieIntake()
        fetchTodayHeartRate()
        fetchTodayActive()
        Task {
            await refreshChallenges()
            await checkExpiredChallenges()
            await fetchCompletedChallenges()
            await fetchActiveChallenges()
        }
    }
    
    func fetchTodayCalories() {
        Logger.info("Fetching today’s calories")
        healthManager.fetchTodayCaloriesBurned { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Calories", subtitle: "Today", image: "flame", tintColor: .red) { value in
                self.calories = Int(value)
                return value.formattedNumberString()
            }
        }
    }
    
    func fetchTodaySteps() {
        Logger.info("Fetching today’s steps")
        healthManager.fetchTodaySteps { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Steps", subtitle: "Today", image: "shoeprints.fill", tintColor: .green) { value in
                self.steps = Int(value)
                return value.formattedNumberString()
            }
        }
    }
    
    func fetchTodayDistance() {
        Logger.info("Fetching today’s distance")
        healthManager.fetchTodayDistance { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Distance", subtitle: "Today", image: "figure.walk", tintColor: .blue) { value in
                self.distanceString = String(format: "%.1f km", value)
                self.distance = Int(value)
                return self.distanceString
            }
        }
    }
    
    func fetchTodayCalorieIntake() {
        Logger.info("Fetching today’s caloric intake")
        healthManager.fetchTodayCalorieIntake { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Caloric Intake", subtitle: "Today", image: "fork.knife", tintColor: .teal) { value in
                return value.formattedNumberString()
            }
        }
    }
    
    func fetchTodayHeartRate() {
        Logger.info("Fetching today’s HR")
        healthManager.fetchTodayHeartRate { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Heart Rate", subtitle: "Today", image: "heart.fill", tintColor: .pink) { value in
                return value.formattedNumberString()
            }
        }
    }
    
    func fetchTodayActive() {
        Logger.info("Fetching today’s active minutes")
        healthManager.fetchTodayActiveMinutes { [weak self] result in
            guard let self else { return }
            self.handleFetchResult(result, title: "Active", subtitle: "Today", image: "figure.run", tintColor: .yellow) { value in
                return "\(value.formattedNumberString()) min"
            }
        }
    }
    
    /// Helper function to handle fetch results
    private func handleFetchResult(
        _ result: Result<Double, Error>,
        title: String,
        subtitle: String,
        image: String,
        tintColor: Color,
        format: @escaping (Double) -> String
    ) {
        switch result {
        case .success(let value):
            DispatchQueue.main.async {
                Logger.success("\(title): \(value)")
                let activity = ActivityCard(
                    id: UUID().hashValue,
                    title: title,
                    subtitle: subtitle,
                    image: image,
                    tintColor: tintColor,
                    amount: format(value)
                )
                self.activities.append(activity)
                self.sortActivities()
            }
        case .failure(let error):
            DispatchQueue.main.async {
                if title == "Distance" {
                    self.distanceString = "0 km"
                }
                Logger.error("\(title) fetch failed: \(error.localizedDescription)")
                let activity = ActivityCard(
                    id: UUID().hashValue,
                    title: title,
                    subtitle: "Today",
                    image: image,
                    tintColor: tintColor,
                    amount: "0"
                )
                self.activities.append(activity)
                self.sortActivities()
            }
        }
    }
    
    private func sortActivities() {
        self.activities.sort { lhs, rhs in
            guard let lhsIndex = activityOrder.firstIndex(of: lhs.title),
                  let rhsIndex = activityOrder.firstIndex(of: rhs.title) else {
                return false
            }
            return lhsIndex < rhsIndex
        }
    }
    
    func toggleEditor() {
        self.showEditGoal.toggle()
    }
    
    func setCurrentGoals() {
        DispatchQueue.main.async {
            self.calorieGoal = self.currentCalorieGoal
            self.stepGoal = self.currentStepGoal
            self.distanceGoal = self.currentDistanceGoal
        }
        
        Task {
            try await Task.sleep(nanoseconds: 200_000_000) // 200 milliseconds
            print("Saving updated goals: Calorie=\(self.calorieGoal), Steps=\(self.stepGoal), Distance=\(self.distanceGoal)")
            await self.saveGoals()
        }
    }
    
    func isGoalsSet() -> Bool {
        return self.calorieGoal != 0 || self.stepGoal != 0 || self.distanceGoal != 0
    }
    
}

extension HomeViewModel {
    private func saveGoals() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            try await UserManager.shared.updateUserGoals(
                userId: userId,
                calorieGoal: round(calorieGoal),
                stepGoal: round(stepGoal),
                distanceGoal: round(distanceGoal)
            )
        } catch {
            print("Failed to save goals: \(error.localizedDescription)")
        }
    }
    
    
    private func fetchGoals() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            if let goals = try await UserManager.shared.getUserGoals(userId: userId) {
                self.calorieGoal = goals.calorieGoal
                self.currentCalorieGoal = goals.calorieGoal
                self.stepGoal = goals.stepGoal
                self.currentStepGoal = goals.stepGoal
                self.distanceGoal = goals.distanceGoal
                self.currentDistanceGoal = goals.distanceGoal
            }
        } catch {
            print("Failed to fetch goals: \(error.localizedDescription)")
        }
    }
}

extension HomeViewModel {
    func fetchActiveChallenges() async {
        activeChallenges.removeAll()
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            self.activeChallenges = user.activeChallenges ?? []
            addChallengeCards()
        } catch {
            print("Failed to fetch active challenges: \(error.localizedDescription)")
        }
    }
    
    func addChallengeCards() {
        challenges.removeAll()
        
        for challenge in activeChallenges {
            let (image, tintColor): (String, Color)
            switch challenge.type {
            case "Distance":
                (image, tintColor) = ("figure.walk", Color.blue)
            case "Steps":
                (image, tintColor) = ("shoeprints.fill", Color.green)
            case "Calories":
                (image, tintColor) = ("flame", Color.red)
            default:
                (image, tintColor) = ("questionmark.circle", Color.gray)
            }
            let card = ChallengeCard(challenge: challenge, image: image, tintColor: tintColor)
            self.challenges.append(card)
        }
    }
}


// MARK: Check challenges
extension HomeViewModel {
    
    func fetchCompletedChallenges() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            self.completedChallenges.removeAll()
            let allChallenges = try await UserManager.shared.fetchPastChallenges(userId: userId)
            let completedChallenges = allChallenges.filter { $0.isCompleted }
            
            DispatchQueue.main.async {
                self.completedChallenges = completedChallenges
            }
        } catch {
            print("Failed to fetch past challenges: \(error.localizedDescription)")
        }
    }
    
    func checkExpiredChallenges() async {
        do {
            let userId = AuthenticationManager.shared.getAuthenticatedUserId()
            try await UserManager.shared.moveExpiredChallenges(userId: userId)
            await fetchActiveChallenges() // Refresh active challenges
        } catch {
            print("Failed to check expired challenges: \(error.localizedDescription)")
        }
    }
    func startDailyUpdate() {
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in // Every 24 hours
            Task {
                await self.checkExpiredChallenges()
            }
        }
    }
}

import HealthKit

extension HomeViewModel {
    
    func completeChallenge(_ challengeId: String) async {
        do {
            let userId = AuthenticationManager.shared.getAuthenticatedUserId()
            try await UserManager.shared.completeChallenge(userId: userId, challengeId: challengeId)
            print("Successfully completed challenge.")
            await fetchActiveChallenges() // Refresh active challenges
        } catch {
            print("Failed to complete challenge: \(error.localizedDescription)")
        }
    }
}

extension HomeViewModel {
    func refreshChallenges() async {
        do {
            let userId = AuthenticationManager.shared.getAuthenticatedUserId()
            
            for challenge in activeChallenges {
                HealthKitManager.shared.fetchChallengeData(
                    type: challenge.type,
                    startDate: challenge.startDate,
                    endDate: Date()
                ) { [weak self] result in
                    switch result {
                    case .success(let progress):
                        self?.updateChallengeProgress(challenge: challenge, progress: progress)
                    case .failure(let error):
                        print("Failed to fetch \(challenge.type) data: \(error.localizedDescription)")
                    }
                }
            }
            
            await fetchActiveChallenges()
        } catch {
            print("Failed to refresh challenges: \(error.localizedDescription)")
        }
    }
    
    private func updateChallengeProgress(challenge: ActiveChallenge, progress: Double) {
        if progress >= Double(challenge.points) {
            Task {
                await completeChallenge(challenge.challengeId)
            }
        } else {
            print("Challenge \(challenge.title) progress: \(progress)/\(challenge.points)")
        }
    }
}
