//
//  NutrientDayView.swift
//  HealthChallenge
//
//  Created by Lova Thorén on 2025-01-07.
//

import SwiftUI

struct NutrientDayView: View {
    @State var nutrient: DailyNutrient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
               
                Text(nutrient.date.monthAndDate)
                    .font(.title2)
                    .bold()
                
                
                Text("\(nutrient.calories) kcal")
                    .font(.subheadline)
            }
            .frame(width: 90, alignment: .leading)
            
            HStack {
                VStack {
                    Text("Carbs")
                    
                    Text("\(nutrient.carbs) g")
                }
                .frame(width: 60, height: 50)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                
                VStack {
                    Text("Protein")
                    
                    Text("\(nutrient.protein) g")
                }
                .frame(width: 60, height: 50)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                
                VStack {
                    Text("Fat")
                    
                    Text("\(nutrient.fat) g")
                }
                .frame(width: 60, height: 50)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.theme.accent.opacity(0.1))
                )
            }
        }
    }
}

#Preview {
    NutrientDayView(nutrient: DailyNutrient(date: .now, calories: 2314, carbs: 143, protein: 20, fat: 134))
}
