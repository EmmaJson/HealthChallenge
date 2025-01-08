//
//  NutrientViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-08.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class NutrientViewModel {
    var calories: Int = 0
    var carbs: Int = 0
    var protein: Int = 0
    var fat: Int = 0
    var dailyNutrients = [DailyNutrient]()
    var showNutrient = false
    var food = ""
    
    private var nutrient = [NutrientModel]()
    
    init(nutrient: [NutrientModel]) {
        updateNutrients(nutrients: nutrient)
    }
    
    func updateNutrients(nutrients: [NutrientModel]) {
            self.nutrient = nutrients
            fetchTodayNutrients()
            fetchDailyNutrients()
        }

    
    private func fetchDailyNutrients() {
        let todayStart = Calendar.current.startOfDay(for: .now)
        let dates: Set<Date> = Set(nutrient.map({ Calendar.current.startOfDay(for: $0.date) }))
        
        var dailyNutrient = [DailyNutrient]()
        for date in dates {
            guard date != todayStart else { continue }
            let filteredNutrients = nutrient.filter({ Calendar.current.startOfDay(for: $0.date) == date })
            let calories: Int = filteredNutrients.reduce(0, { $0 + $1.calories })
            let carbs: Int = filteredNutrients.reduce(0, { $0 + $1.carbs })
            let protein: Int = filteredNutrients.reduce(0, { $0 + $1.proteins })
            let fat: Int = filteredNutrients.reduce(0, { $0 + $1.fats })
            let nutrient = DailyNutrient(date: date, calories: calories, carbs: carbs, protein: protein, fat: fat)
            dailyNutrient.append(nutrient)
        }
        self.dailyNutrients = dailyNutrient.sorted(by: { $0.date > $1.date })
    }
    
    private func fetchTodayNutrients() {
        let todayNutrients = nutrient.filter { Calendar.current.isDateInToday($0.date) }
        
        let totalCalories = todayNutrients.reduce(0) { $0 + $1.calories }
        let totalCarbs = todayNutrients.reduce(0) { $0 + $1.carbs }
        let totalProtein = todayNutrients.reduce(0) { $0 + $1.proteins }
        let totalFat = todayNutrients.reduce(0) { $0 + $1.fats }
        
        calories = totalCalories
        carbs = totalCarbs
        protein = totalProtein
        fat = totalFat
    }
    
    
}

