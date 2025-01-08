//
//  NutrientModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation
import SwiftData

@Model
final class NutrientModel {
    let food: String
    let createdAt: Date
    let date: Date
    let calories: Int
    let carbs: Int
    let proteins: Int
    let fats: Int
    
    init(food: String, createdAt: Date, date: Date, calories: Int, carbs: Int, proteins: Int, fats: Int) {
        self.food = food
        self.createdAt = createdAt
        self.date = date
        self.calories = calories
        self.carbs = carbs
        self.proteins = proteins
        self.fats = fats
    }
}

