//
//  PayloadModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTChatpayload: Encodable {
    let model: String
    let messages: [GPTMessage]
    let functions: [GPTFunction]
}
