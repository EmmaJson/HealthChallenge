//
//  FunctionModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import Foundation

struct GPTFunction: Encodable {
    let name: String
    let description: String
    let parameters: GPTFuncionParameter
}
