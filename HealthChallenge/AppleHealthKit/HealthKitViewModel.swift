//
//  HealthKitViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import Foundation
import Combine
import HealthKit

enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}

enum MetricType: String, CaseIterable, Identifiable {
    case steps = "Steps"
    case calories = "Calories"
    case distance = "Distance"

    var id: String { rawValue }
}

@MainActor
final class HealthKitViewModel: ObservableObject {
    @Published var labels: [String] = []
    @Published var data: [Double] = []
    @Published var average: Double = 0
    @Published var total: Double = 0
    @Published var errorMessage: String? = nil
    
    @Published var selectedTimePeriod: TimePeriod = .day {
        didSet { fetchData() }
    }
    
    @Published var selectedMetric: MetricType = .steps {
        didSet { fetchData() }
    }
    
    @Published var isLoading = true

    private var healthKitManager = HealthKitManager.shared

    init() {
        fetchData()
    }

    func fetchData() {
        isLoading = true
        let now = Date()
        let calendar = Calendar.current
        var startDate: Date
        var endDate: Date
        var interval: Calendar.Component

        switch selectedTimePeriod {
        case .day:
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            interval = .hour
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
            endDate = now
            interval = .day
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            endDate = now
            interval = .day
        case .year:
            endDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            startDate = calendar.date(byAdding: .month, value: -11, to: endDate)!
            interval = .month
        }

        switch selectedMetric {
        case .steps:
            fetchStepsData(interval: interval, startDate: startDate, endDate: endDate)
        case .calories:
            fetchCaloriesData(interval: interval, startDate: startDate, endDate: endDate)
        case .distance:
            fetchDistanceData(interval: interval, startDate: startDate, endDate: endDate)
        }
    }

    private func fetchStepsData(interval: Calendar.Component, startDate: Date, endDate: Date) {
        healthKitManager.fetchSteps(interval: interval, startDate: startDate, endDate: endDate) { [weak self] data, labels, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.data = data.compactMap { $0 }
                    self?.labels = labels
                    self?.total = self?.data.reduce(0, +) ?? 0.0
                    self?.average = self?.data.isEmpty == false ? (self?.total ?? 0.0) / Double(self?.data.count ?? 1) : 0.0
                    
                    if self?.selectedTimePeriod == .year {
                        self?.total = (self?.average ?? 0) * 365
                    }
                }
                self?.isLoading = false
            }
        }
    }

    private func fetchCaloriesData(interval: Calendar.Component, startDate: Date, endDate: Date) {
        healthKitManager.fetchCalories(interval: interval, startDate: startDate, endDate: endDate) { [weak self] data, labels, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.data = data.compactMap { $0 }
                    self?.labels = labels
                    self?.total = self?.data.reduce(0, +) ?? 0.0
                    self?.average = self?.data.isEmpty == false ? (self?.total ?? 0.0) / Double(self?.data.count ?? 1) : 0.0
                    
                    if self?.selectedTimePeriod == .year {
                        self?.total = (self?.average ?? 0) * 365
                    }
                }
                self?.isLoading = false
            }
        }
    }

    private func fetchDistanceData(interval: Calendar.Component, startDate: Date, endDate: Date) {
        healthKitManager.fetchDistance(interval: interval, startDate: startDate, endDate: endDate) { [weak self] data, labels, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.data = data.compactMap { $0 }
                    self?.labels = labels
                    self?.total = self?.data.reduce(0, +) ?? 0.0
                    self?.average = self?.data.isEmpty == false ? (self?.total ?? 0.0) / Double(self?.data.count ?? 1) : 0.0
                    
                    if self?.selectedTimePeriod == .year {
                        self?.total = (self?.average ?? 0) * 365
                    }
                }
                self?.isLoading = false
            }
        }
    }
}
