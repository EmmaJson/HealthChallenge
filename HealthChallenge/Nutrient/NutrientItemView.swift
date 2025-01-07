//
//  NutrientItemView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import SwiftUI

struct NutrientItemView: View {
    @Binding var carbs: Double
    @Binding var protein: Double
    @Binding var fat: Double
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image("Carbs")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .padding(.horizontal)
                Text("Carbs")
                
                Text("\(carbs.formattedNumberString()) g")
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
                    .frame(width: 50)
                    .padding(.horizontal)
                Text("Protein")
                
                Text("\(protein.formattedNumberString()) g")
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
                    .frame(width: 50)
                    .padding(.horizontal)
                Text("Fat")
                
                Text("\(fat.formattedNumberString()) g")
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

#Preview {
    NutrientItemView(carbs: .constant(32), protein: .constant(120), fat: .constant(56))
}
