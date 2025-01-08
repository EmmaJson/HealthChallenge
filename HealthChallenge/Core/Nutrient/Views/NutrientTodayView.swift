//
//  NutrientItemView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import SwiftUI

struct NutrientTodayView: View {
    var calories: Int
    var carbs: Int
    var protein: Int
    var fat: Int
    
    var body: some View {
        VStack {
            Text("Calories \(calories) kcal")
                .font(.subheadline)
            HStack {
                Spacer()
                
                VStack {
                    Image("Carbs")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(.horizontal)
                    Text("Carbs")
                    
                    Text("\(carbs) g")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                Spacer()
                
                VStack {
                    Image("Protein")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(.horizontal)
                    Text("Protein")
                    
                    Text("\(protein) g")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                Spacer()
                
                VStack {
                    Image("Fat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(.horizontal)
                    Text("Fat")
                    
                    Text("\(fat) g")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                Spacer()
            }
        }

    }
}
