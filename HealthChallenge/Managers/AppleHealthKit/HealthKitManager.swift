//
//  HealthKitManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    
    private init() {
        Logger.info("Initializing HealthKitManager")
        authorizeHealthKit { result in
            switch result {
            case .success(let authorized):
                if authorized {
                    Logger.success("HealthKit authorization successful.")
                } else {
                    Logger.error("HealthKit authorization denied.")
                }
            case .failure(let error):
                Logger.error("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func authorizeHealthKit(completion: @escaping (Result<Bool, Error>) -> Void) {
        Logger.info("Requesting HealthKit authorization")
        
        let healthTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        // Check the current authorization status
        healthStore.getRequestStatusForAuthorization(toShare: [], read: healthTypes) { status, error in
            if let error = error {
                Logger.error("Authorization request status error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            switch status {
            case .unnecessary:
                Logger.info("Authorization already granted")
                completion(.success(true))
            default:
                self.healthStore.requestAuthorization(toShare: [], read: healthTypes) { success, error in
                    if let error = error {
                        Logger.error("HealthKit request error: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        Logger.success("HealthKit authorization request completed with success: \(success)")
                        completion(.success(success))
                    }
                }
            }
        }
    }
}

// MARK: Fetch-quantity
extension HealthKitManager {
    func fetchTodayQuantity(
        type: HKQuantityType,
        unit: HKUnit,
        options: HKStatisticsOptions = .cumulativeSum,
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        Logger.info("Fetching today’s data for type: \(type.identifier)")
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: options
        ) { _, results, error in
            if let error = error {
                Logger.error("Error fetching data for \(type.identifier): \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let quantity = (options == .discreteAverage ? results?.averageQuantity() : results?.sumQuantity()) {
                let value = quantity.doubleValue(for: unit)
                Logger.success("Successfully fetched value \(value) for \(type.identifier)")
                completion(.success(value))
            } else {
                Logger.error("No data available for type: \(type.identifier)")
                completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available for \(type.identifier)"])))
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodaySteps(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count type unavailable."])))
            return
        }
        fetchTodayQuantity(type: stepsType, unit: HKUnit.count(), completion: completion)
    }
    
    func fetchTodayDistance(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Distance type unavailable."])))
            return
        }
        fetchTodayQuantity(type: distanceType, unit: HKUnit.meterUnit(with: .kilo), completion: completion)
    }
    
    func fetchTodayCaloriesBurned(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calories type unavailable."])))
            return
        }
        fetchTodayQuantity(type: caloriesType, unit: HKUnit.kilocalorie(), completion: completion)
    }
    
    func fetchTodayHeartRate(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Heart rate type unavailable."])))
            return
        }
        fetchTodayQuantity(
            type: heartRateType,
            unit: HKUnit(from: "count/min"),
            options: .discreteAverage,
            completion: completion
        )
    }
    
    func fetchTodayActiveMinutes(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let activeMinutesType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Active minutes type unavailable."])))
            return
        }
        fetchTodayQuantity(type: activeMinutesType, unit: HKUnit.minute(), completion: completion)
    }
    
    func fetchTodayCalorieIntake(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let calorieIntakeType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calorie intake type unavailable."])))
            return
        }
        fetchTodayQuantity(
            type: calorieIntakeType,
            unit: HKUnit.kilocalorie(),
            completion: completion
        )
    }
}

// MARK: LeaderboardView
extension HealthKitManager {
    func fetchCurrentWeekStepCount(completion: @escaping (Result<Double,Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Date().fetchPreviousMonday(), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let stepsCount = quantity.doubleValue(for: .count())
            completion(.success(stepsCount))
        }
        healthStore.execute(query)
    }
    
}

// MARK: Fetch data for charts
extension HealthKitManager {
    private func fetchData(
        type: HKQuantityType,
        unit: HKUnit,
        interval: Calendar.Component,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([Double?], [String], Error?) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var intervalComponents = DateComponents()
        switch interval {
        case .hour: intervalComponents.hour = 1
        case .day: intervalComponents.day = 1
        case .month: intervalComponents.month = 1
        case .year: intervalComponents.month = 1 // Use month intervals to calculate yearly averages
        default:
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported interval."]))
            return
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: intervalComponents
        )

        query.initialResultsHandler = { _, results, error in
            if let error = error {
                completion([], [], error)
                return
            }

            let calendar = Calendar.current
            var labels: [String] = []
            var values: [Double?] = []

            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let totalValue = quantity.doubleValue(for: unit)
                    
                    switch interval {
                    case .hour:
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                        values.append(totalValue)
                    case .day:
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                        values.append(totalValue)
                    case .month:
                        let month = calendar.component(.month, from: statistics.startDate)
                        labels.append(calendar.monthSymbols[month - 1])
                        values.append(totalValue / Double(calendar.range(of: .day, in: .month, for: statistics.startDate)?.count ?? 1)) // Average per day in month
                    case .year:
                        let month = calendar.component(.month, from: statistics.startDate)
                        labels.append(calendar.monthSymbols[month - 1])
                        let daysInMonth = calendar.range(of: .day, in: .month, for: statistics.startDate)?.count ?? 1
                        values.append(totalValue / Double(daysInMonth)) // Average per day in month
                    default: break
                    }
                } else {
                    values.append(0.0)

                    switch interval {
                    case .hour:
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                    case .day:
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                    case .month, .year:
                        let month = calendar.component(.month, from: statistics.startDate)
                        labels.append(calendar.monthSymbols[month - 1])
                    default: break
                    }
                }
            }

            completion(values, labels, nil)
        }

        healthStore.execute(query)
    }
}

// MARK: Fetch data for certain chart
extension HealthKitManager {
    func fetchDistance(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Distance data unavailable."]))
            return
        }
        fetchData(type: distanceType, unit: HKUnit.meterUnit(with: .kilo), interval: interval, startDate: startDate, endDate: endDate, completion: completion)
    }

    func fetchCalories(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calories data unavailable."]))
            return
        }
        fetchData(type: caloriesType, unit: HKUnit.kilocalorie(), interval: interval, startDate: startDate, endDate: endDate, completion: completion)
    }

    func fetchSteps(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count data unavailable."]))
            return
        }
        fetchData(type: stepType, unit: HKUnit.count(), interval: interval, startDate: startDate, endDate: endDate, completion: completion)
    }
}
