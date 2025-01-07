//
//  MacroView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import SwiftUI

struct NutrientsView: View {
    @State var carbs: Double = 124
    @State var protein: Double = 140
    @State var fat: Double = 14
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Today")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Spacer()
                    
                    Button {
                        print("ADD")
                    } label: {
                        Image(systemName: "plus")
                            .frame(maxWidth: 40)
                            .padding(.horizontal)
                    }
                }
                
                NutrientItemView(carbs: $carbs, protein: $protein, fat: $fat)
                    .padding()
                
                
                VStack(alignment: .leading) {
                    Text("Previous")
                        .font(.title)
                        .bold()
                    ForEach(0..<5) { _ in
                        NutrientItemView(carbs: .constant(Double.random(in: 10..<200)), protein: .constant(Double.random(in: 10..<200)), fat: .constant(Double.random(in: 10..<200)))
                    }
                }
                .padding()
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.hidden)
        .task {
            do {
                print("Fetch nutrient")
                //try await OpenAIService.shared.sendPromptToGPT(message: "a glass of milk 1% fat")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NutrientsView()
}
