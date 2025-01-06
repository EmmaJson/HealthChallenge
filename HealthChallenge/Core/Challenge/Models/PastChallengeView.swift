//
//  PastChallengeView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import Foundation

struct PastChallenge: Codable {
    let finishedChallengeId = UUID()
    let challenge: ActiveChallenge
    let isCompleted: Bool
}
