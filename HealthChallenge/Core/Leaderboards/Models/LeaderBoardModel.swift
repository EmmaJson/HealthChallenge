//
//  LeaderBoardModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct LeaderboardUser: Codable, Identifiable {
    let id: String
    let username: String
    let calories: Int
    let steps: Int
    let distance: Int
    let points: Int
}
