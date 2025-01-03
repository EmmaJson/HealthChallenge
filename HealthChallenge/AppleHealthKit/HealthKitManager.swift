//
//  HealthKitManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import HealthKit
extension Date {
    static var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2      // Start fetching on monday
        return calendar.date(from: components) ?? Date()
    }
    
    func fetchMonthStartAndEndDate() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var startDateComponent = calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self))
        let startDate = calendar.date(from: startDateComponent) ?? self
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day:-1), to: startDate) ?? self
        return (startDate,endDate)
    }
    
    func fetchPreviousMonday() -> Date {
        var calendar = Calendar.current

        calendar.firstWeekday = 2

        let weekday = calendar.component(.weekday, from: self)

        let daysToSubtract = weekday == 1 ? 6 : weekday - 2
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self) ?? Date()
    }
    
    func mondayDateFormat() -> String {
        let monday = self.fetchPreviousMonday()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: monday)
    }
}

extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}



class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init () {
        Task {
            do {
                try await requestHealthKitAccess()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                print("HealthKit authorization failed: \(String(describing: error?.localizedDescription))")
            }
            completion(success, error)
        }
    }
}

// MARK: Distance
extension HealthKitManager {
    func fetchDistance(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Distance data unavailable."]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var intervalComponents = DateComponents()
        switch interval {
        case .hour:
            intervalComponents.hour = 1
        case .day:
            intervalComponents.day = 1
        case .month:
            intervalComponents.month = 1
        default:
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported interval."]))
            return
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: distanceType,
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
                    let totalDistance = quantity.doubleValue(for: HKUnit.meter())

                    switch interval {
                    case .hour:
                        // Label as "0:00", "1:00", etc., and add raw distance
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                        values.append(totalDistance / 1000.0) // Convert to kilometers
                    case .day:
                        // Label as "1", "2", ..., and add raw distance
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                        values.append(totalDistance / 1000.0) // Convert to kilometers
                    case .month:
                        // Calculate average for each day of the month
                        let daysInMonth = calendar.range(of: .day, in: .month, for: statistics.startDate)?.count ?? 1
                        let averageDistance = totalDistance / Double(daysInMonth) / 1000.0 // Convert to kilometers
                        labels.append(calendar.monthSymbols[calendar.component(.month, from: statistics.startDate) - 1])
                        values.append(averageDistance)
                    default:
                        break
                    }
                } else {
                    // No data for this period
                    values.append(0.0)

                    switch interval {
                    case .hour:
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                    case .day:
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                    case .month:
                        labels.append(calendar.monthSymbols[calendar.component(.month, from: statistics.startDate) - 1])
                    default:
                        break
                    }
                }
            }

            completion(values, labels, nil)
        }

        healthStore.execute(query)
    }
}


// MARK: Calories Burned
extension HealthKitManager {
    func fetchCalories(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calories data unavailable."]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var intervalComponents = DateComponents()
        switch interval {
        case .hour:
            intervalComponents.hour = 1
        case .day:
            intervalComponents.day = 1
        case .month:
            intervalComponents.month = 1
        default:
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported interval."]))
            return
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: caloriesType,
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
            
            var currentPairSum: Double = 0
            var pairCount = 0
            var currentLabelStart: Int = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if interval == .month {
                    let month = calendar.monthSymbols[calendar.component(.month, from: statistics.startDate) - 1]
                    labels.append(month)

                    if let quantity = statistics.sumQuantity() {
                        let totalCalories = quantity.doubleValue(for: HKUnit.kilocalorie())
                        let daysInMonth = calendar.range(of: .day, in: .month, for: statistics.startDate)?.count ?? 1
                        let averageCalories = daysInMonth > 0 ? totalCalories / Double(daysInMonth) : 0.0
                        values.append(round(averageCalories * 100) / 100) // Round to 2 decimal places
                    } else {
                        values.append(0.0) // Default to 0 if no data
                    }
                }
                else {
                    // Handle other intervals (day, week)
                    switch interval {
                    case .hour:
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                    case .day:
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                    case .month:
                        let day = calendar.component(.day, from: statistics.startDate)

                        if pairCount == 0 { // Start a new pair
                            currentLabelStart = day
                        }

                        if let quantity = statistics.sumQuantity() {
                            currentPairSum += quantity.doubleValue(for: HKUnit.kilocalorie())
                            pairCount += 1
                        }

                        if pairCount == 2 || statistics.endDate >= endDate { // Finalize the pair
                            let label = pairCount == 2 ? "\(currentLabelStart)-\(day)" : "\(currentLabelStart)"
                            labels.append(label)
                            values.append(currentPairSum / Double(pairCount)) // Average for the pair

                            // Reset for next pair
                            currentPairSum = 0
                            pairCount = 0
                        }
                    default:
                        break
                    }

                    if let quantity = statistics.sumQuantity() {
                        values.append(quantity.doubleValue(for: HKUnit.kilocalorie()))
                    } else {
                        values.append(0.0) // Default to 0 if no data
                    }
                }
            }

            completion(values, labels, nil)
        }

        healthStore.execute(query)
    }
}


// MARK: Steps
extension HealthKitManager {
    func fetchSteps(interval: Calendar.Component, startDate: Date, endDate: Date, completion: @escaping ([Double?], [String], Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count data unavailable."]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var intervalComponents = DateComponents()
        switch interval {
        case .hour:
            intervalComponents.hour = 1
        case .day:
            intervalComponents.day = 1
        case .month:
            intervalComponents.month = 1
        default:
            completion([], [], NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported interval."]))
            return
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
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
            
            var currentPairSum: Double = 0
            var pairCount = 0
            var currentLabelStart: Int = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if interval == .month {
                    let month = calendar.monthSymbols[calendar.component(.month, from: statistics.startDate) - 1]
                    labels.append(month)

                    if let quantity = statistics.sumQuantity() {
                        let totalSteps = quantity.doubleValue(for: HKUnit.count())
                        let daysInMonth = calendar.range(of: .day, in: .month, for: statistics.startDate)?.count ?? 1
                        let averageSteps = daysInMonth > 0 ? totalSteps / Double(daysInMonth) : 0.0
                        values.append(round(averageSteps * 100) / 100) // Round to 2 decimal places
                    } else {
                        values.append(0.0) // Default to 0 if no data
                    }
                }
                else {
                    // Handle other intervals (day, week)
                    switch interval {
                    case .hour:
                        let hour = calendar.component(.hour, from: statistics.startDate)
                        labels.append("\(hour):00")
                    case .day:
                        let day = calendar.component(.day, from: statistics.startDate)
                        labels.append("\(day)")
                    case .month:
                        let day = calendar.component(.day, from: statistics.startDate)

                        if pairCount == 0 { // Start a new pair
                            currentLabelStart = day
                        }

                        if let quantity = statistics.sumQuantity() {
                            currentPairSum += quantity.doubleValue(for: HKUnit.count())
                            pairCount += 1
                        }

                        if pairCount == 2 || statistics.endDate >= endDate { // Finalize the pair
                            let label = pairCount == 2 ? "\(currentLabelStart)-\(day)" : "\(currentLabelStart)"
                            labels.append(label)
                            values.append(currentPairSum / Double(pairCount)) // Average for the pair

                            // Reset for next pair
                            currentPairSum = 0
                            pairCount = 0
                        }
                    default:
                        break
                    }

                    if let quantity = statistics.sumQuantity() {
                        values.append(quantity.doubleValue(for: HKUnit.count()))
                    } else {
                        values.append(0.0) // Default to 0 if no data
                    }
                }
            }
            completion(values, labels, nil)
        }

        healthStore.execute(query)
    }
}

extension HealthKitManager {
    func requestHealthKitAccess() async throws {
        let calories = HKQuantityType(.activeEnergyBurned)
        let steps = HKQuantityType(.stepCount)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let calorieIntake = HKQuantityType(.dietaryEnergyConsumed)
        let heartRate = HKQuantityType(.heartRate)
        let activiveMin = HKQuantityType(.appleExerciseTime)
        
        let healthTypes: Set = [calories, steps, distance, calorieIntake, heartRate, activiveMin]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodayCaloriedBurned(completion: @escaping(Result<Double,Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let burnedCalorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(burnedCalorieCount))
        }
        healthStore.execute(query)
    }
    
    func fetchTodaySteps(completion: @escaping(Result<Double,Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
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
    
    func fetchTodayDistance(completion: @escaping(Result<Double,Error>) -> Void) {
        let distance = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let distanceCount = quantity.doubleValue(for: .meterUnit(with: .kilo))
            completion(.success(distanceCount))
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalorieIntake(completion: @escaping (Result<Double, Error>) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
        }
        healthStore.execute(query)
    }

    func fetchTodayHeartRate(completion: @escaping (Result<Double, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, results, error in
            guard let quantity = results?.averageQuantity(), error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            
            let heartRate = quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(.success(heartRate))
        }
        healthStore.execute(query)
    }
    
    func fetchTodayActiveMinutes(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let activeMinutesType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(.failure(NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Active minutes data unavailable."])))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        
        let query = HKStatisticsQuery(quantityType: activeMinutesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            
            let activeMinutes = quantity.doubleValue(for: HKUnit.minute())
            completion(.success(activeMinutes))
        }
        healthStore.execute(query)
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

