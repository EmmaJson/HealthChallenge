//
//  FunctionCallModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTFunctionCall: Decodable {
    let name: String
    let arguments: String
}
