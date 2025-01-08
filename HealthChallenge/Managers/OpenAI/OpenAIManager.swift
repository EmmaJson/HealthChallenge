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

enum OpenAIError: Error {
    case noFunctionCall
    case unableToConvertStringToData
}

class OpenAIManager {
    
    static let shared = OpenAIManager()
    
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
        let calories = GPTFunctionProperty(type: "integer", description: "The amount of calories (kcal) in grams of the given food item")
        let fats = GPTFunctionProperty(type: "integer", description: "The amount of fats in grams of the given food item")
        let carbs = GPTFunctionProperty(type: "integer", description: "The amount of carbs in grams of the given food item")
        let proteins = GPTFunctionProperty(type: "integer", description: "The amount of proteins in grams of the given food item")
        let params: [String: GPTFunctionProperty] = [
            "food": food,
            "calories": calories,
            "fats": fats,
            "carbs": carbs,
            "proteins": proteins
        ]
        
        let funcionParams = GPTFuncionParameter(type: "object", properties: params, required: ["food", "calories", "fats", "carbs", "proteins"])
        let function = GPTFunction(name: "get_macronutrients", description: "Get the micronutrients for a given food", parameters: funcionParams)
        
        let payload = GPTChatpayload(model: "gpt-3.5-turbo", messages: [systemMessage, userMessage], functions: [function])
        
        let jsonData = try JSONEncoder().encode(payload)
        
        urlRequest.httpBody = jsonData
        return urlRequest
    }
    
    func sendPromptToGPT(message: String) async throws  -> MacroResult {
        let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        let result = try JSONDecoder().decode(GPTResponse.self, from: data)

        guard let functionCall = result.choices[0].message.functionCall else {
            throw OpenAIError.noFunctionCall
        }
        guard let argData = functionCall.arguments.data(using: .utf8) else {
            throw OpenAIError.unableToConvertStringToData
        }
        let macroResponse = try JSONDecoder().decode(MacroResult.self, from: argData)
        return macroResponse
    }
}
