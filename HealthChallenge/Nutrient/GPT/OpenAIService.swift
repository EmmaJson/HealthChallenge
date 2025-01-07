//
//  OpenAIService.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

class OpenAIService {
    static let shared = OpenAIService()
    
    private init() { }
    
    private func generateURLRequest(httpMethod: HTTPMethod, message: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        
        // Method
        urlRequest.httpMethod = httpMethod.rawValue
        
        // Header
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Secrets.apiKey)", forHTTPHeaderField: "Authorization")
        
        // Body
        let systemMessage = GPTMessage(role: "system", content: "You are a macronuctient expert.")
        let userMessage = GPTMessage(role: "user", content: message)
        
        let food = GPTFunctionProperty(type: "string", description: "The food item e. g. pizza")
        let fats = GPTFunctionProperty(type: "number", description: "The amount of fats in grams of the given food item")
        let carbs = GPTFunctionProperty(type: "number", description: "The amount of carbs in grams of the given food item")
        let proteins = GPTFunctionProperty(type: "number", description: "The amount of proteins in grams of the given food item")
        let params: [String: GPTFunctionProperty] = [
            "food": food,
            "fats": fats,
            "carbs": carbs,
            "proteins": proteins
        ]
        
        let funcionParams = GPTFuncionParameter(type: "object", properties: params, required: ["food", "fats", "carbs", "proteins"])
        let function = GPTFunction(name: "get_macronutrients", description: "Get the micronutrients for a given food", parameters: funcionParams)
        
        let payload = GPTChatpayload(model: "gpt-3.5-turbo", messages: [systemMessage, userMessage], functions: [function])
        
        let jsonData = try JSONEncoder().encode(payload)
        
        urlRequest.httpBody = jsonData
        return urlRequest
    }
    
    func sendPromptToGPT(message: String) async throws {
        let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print(String(data: data, encoding: .utf8)!)
    }
}

struct GPTChatpayload: Encodable {
    let model: String
    let messages: [GPTMessage]
    let functions: [GPTFunction]
}

struct GPTMessage: Encodable {
    let role: String
    let content: String
}

struct GPTFunction: Encodable {
    let name: String
    let description: String
    let parameters: GPTFuncionParameter
}

struct GPTFuncionParameter: Encodable {
    let type: String
    let properties: [String: GPTFunctionProperty]?
    let required: [String]?
}

struct GPTFunctionProperty: Encodable {
    let type: String
    let description: String
}
