//
//  FunctionParamModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTFuncionParameter: Encodable {
    let type: String
    let properties: [String: GPTFunctionProperty]?
    let required: [String]?
}
