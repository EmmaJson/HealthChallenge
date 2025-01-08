//
//  DailyNutrientModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation


struct DailyNutrient: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
}
