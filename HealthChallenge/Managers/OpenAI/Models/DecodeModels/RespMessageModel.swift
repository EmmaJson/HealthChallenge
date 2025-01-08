//
//  RespMessageModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTRespMessage: Decodable {
    let functionCall: GPTFunctionCall?
    
    enum CodingKeys: String, CodingKey {
        case functionCall = "function_call"
    }
}
