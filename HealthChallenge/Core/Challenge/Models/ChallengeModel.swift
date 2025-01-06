//
//  ChallengeModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import Foundation


struct Challenge: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let points: Int
    let type: String
    let interval: String
    let createdDate = Date()
}
