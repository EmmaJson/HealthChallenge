//
//  MacroView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import SwiftUI
import SwiftData

struct NutrientsView: View {
    @Environment(\.modelContext) var modelContext
    @State var viewModel: NutrientViewModel
    @Query var nutrient: [NutrientModel]

        init() {
            _viewModel = State(wrappedValue: NutrientViewModel(nutrient: []))
        }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Today")
                        .font(.title)
                        .bold()
                        .padding(.top)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showNutrient = true
                    } label: {
                        Image(systemName: "plus")
                            .frame(maxWidth: 40)
                            .padding(.horizontal)
                    }
                }
                
                NutrientTodayView(calories: viewModel.calories, carbs: viewModel.carbs, protein: viewModel.protein, fat: viewModel.fat)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Previous")
                        .font(.title)
                        .bold()
                    ForEach(viewModel.dailyNutrients) { nutrient in
                        NutrientDayView(nutrient: nutrient)
                    }
                }
                .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $viewModel.showNutrient) {
            AddNutrientView()
                .presentationDetents([.fraction(0.4)])
        }
        .onAppear {
            viewModel.updateNutrients(nutrients: nutrient)
        }
        .onChange(of: nutrient) { _, _ in
            viewModel.updateNutrients(nutrients: nutrient)
        }
    }
}

#Preview {
    NutrientsView()
}
