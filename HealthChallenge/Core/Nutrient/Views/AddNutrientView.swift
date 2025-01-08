//
//  AddNutrientView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-07.
//

import SwiftUI

struct AddNutrientView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var food = ""
    @State private var date: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add meal or food")
                .font(.largeTitle)
                .bold()
            
            TextField("What did you eat?", text: $food)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
            )
            
            DatePicker("Date", selection: $date)
            
            Button {
                if food.count > 2 {
                    sendPromptToGPT()
                    dismiss()
                }
            } label: {
                Text("Done")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.theme.background)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.theme.colorBlue)
                        )
            }
            
        }
        .padding(.horizontal)
        .alert("Ooops", isPresented: $showAlert) {
            Button("Ok", action: { showAlert = false })
        } message: {
            Text(alertMessage)
        }

    }
    
    private func sendPromptToGPT() {
        Task {
            do {
                let result = try await OpenAIManager.shared.sendPromptToGPT(message: food)
                saveNutrient(result)
            } catch {
                if let openAIError = error as? OpenAIError {
                    switch openAIError {
                    case .noFunctionCall:
                        showAlert = true
                        alertMessage = "We were to calculate the macronutrients for this food. Please make sure to enter a valid food name, and try again"
                    case .unableToConvertStringToData:
                        showAlert = true
                        alertMessage = "There was an issue adding your meal"
                    }
                } else {
                    showAlert = true
                    alertMessage = "There was an issue adding your meal"
                }
            }
        }
    }
    
    private func saveNutrient(_ result: MacroResult) {
        let nutrients = NutrientModel(food: result.food, createdAt: .now, date: date, calories: result.calories, carbs: result.carbs, proteins: result.proteins, fats: result.fats)
        modelContext.insert(nutrients)
        print(nutrients)
        print(nutrients.food)
    }
}

#Preview {
    AddNutrientView()
}
