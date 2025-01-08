//
//  MacroRespModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

struct MacroResult: Decodable {
    let food: String
    let calories: Int
    let carbs: Int
    let proteins: Int
    let fats: Int
}
