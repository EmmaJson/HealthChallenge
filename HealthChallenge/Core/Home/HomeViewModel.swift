//
//  HomeViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    let healthManager = HealthKitManager.shared
    
    @Published var calories: Int = 0
    @Published var steps: Int = 0
    @Published var distance: Int = 0
    @Published var distanceString: String = ""
 
    @Published var activities = [ActivityCard]()
    
    var mockChallenges = [
        ChallengeCard(challenge: Challenge(id: "0", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .green),
        ChallengeCard(challenge: Challenge(id: "1", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .purple),
        ChallengeCard(challenge: Challenge(id: "3", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .yellow),
        ChallengeCard(challenge: Challenge(id: "4", title: "Challenge Title", description: "Challenge Description", points: 100, isDaily: true, isWeekly: false, isMonthly: false, createdDate: Date()), image: "figure.run", tintColor: .blue),
    ]
    
    init() {
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
                fetchTodayCalories()
                fetchTodaySteps()
                fetchTodayDistance()
                fetchTodayCalorieIntake()
                fetchTodayHeartRate()
                fetchTodayActive()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func refreshData() {
        DispatchQueue.main.async {
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
        healthManager.fetchTodayCaloriedBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    let activity = ActivityCard(id: 0, title: "Calories", subtitle: "Today", image: "flame", tintColor: .red, amount: calories.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failture):
                print(failture.localizedDescription)
            }
        }
    }
    
    func fetchTodaySteps() {
        healthManager.fetchTodaySteps { result in
            switch result {
            case .success(let steps):
                DispatchQueue.main.async {
                    self.steps = Int(steps)
                    let activity = ActivityCard(id: 1, title: "Steps", subtitle: "Today", image: "shoeprints.fill", tintColor: .green, amount: steps.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failture):
                print(failture.localizedDescription)
            }
        }
    }
    
    func fetchTodayDistance() {
        healthManager.fetchTodayDistance { result in
            switch result {
            case .success(let kilometers):
                DispatchQueue.main.async {
                    self.distanceString = String(format: "%.1f", kilometers)
                    self.distance = Int(kilometers)
                    let activity = ActivityCard(id: 2, title: "Distance", subtitle: "Today", image: "figure.walk", tintColor: .blue, amount: self.distanceString+" km")
                    self.activities.append(activity)
                }
            case .failure(let failture):
                print(failture.localizedDescription)
            }
        }
    }
    
    func fetchTodayCalorieIntake() {
        healthManager.fetchTodayHeartRate { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    let activity = ActivityCard(id: 3, title: "Caloric Intake", subtitle: "Today", image: "fork.knife", tintColor: .teal, amount: calories.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func fetchTodayHeartRate() {
        healthManager.fetchTodayHeartRate { result in
            switch result {
            case .success(let heartRate):
                DispatchQueue.main.async {
                    let activity = ActivityCard(id: 4, title: "Heart Rate", subtitle: "Today", image: "heart.fill", tintColor: .pink, amount: heartRate.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    //Find another feature
    func fetchTodayActive() {
        healthManager.fetchTodayActiveMinutes { result in
            switch result {
            case .success(let active):
                DispatchQueue.main.async {
                    let activity = ActivityCard(id: 5, title: "Active", subtitle: "Today", image: "figure.run", tintColor: .yellow, amount: active.formattedNumberString()+" min")
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
