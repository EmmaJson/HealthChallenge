//
//  ActiveChallengeModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import Foundation

struct ActiveChallenge: Codable {
    let challengeId: String
    let title: String
    let description: String
    let points: Int
    let type: String
    let interval: String
    let startDate: Date
    let endDate: Date
}
