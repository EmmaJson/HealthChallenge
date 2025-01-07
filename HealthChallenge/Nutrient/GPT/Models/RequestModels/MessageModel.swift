//
//  MessageModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTMessage: Encodable {
    let role: String
    let content: String
}
