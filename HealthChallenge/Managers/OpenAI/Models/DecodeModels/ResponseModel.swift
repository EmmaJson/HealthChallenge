//
//  ResponseModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTResponse: Decodable {
    let choices: [GPTCompletion]
}
