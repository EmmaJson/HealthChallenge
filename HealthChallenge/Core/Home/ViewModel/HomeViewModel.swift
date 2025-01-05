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
    
    private let activityOrder = ["Calories", "Steps", "Distance", "Heart Rate", "Active", "Caloric Intake"]
    
    var mockChallenges = [
        ChallengeCard(challenge: Challenge(id: "0", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .green),
        ChallengeCard(challenge: Challenge(id: "1", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .purple),
        ChallengeCard(challenge: Challenge(id: "3", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .yellow),
        ChallengeCard(challenge: Challenge(id: "4", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .blue),
    ]
    
    init() {
        Logger.info("Initializing HomeViewModel")
        authorizeAndFetchData()
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
}
