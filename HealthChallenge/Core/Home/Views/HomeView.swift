//
//  HomeView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel = HomeViewModel()
        
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                HStack {
                    VStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.red)
                            Text("\(viewModel.calories)")
                                .bold()
                            
                            Text("Steps")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.green)
                            Text("\(viewModel.steps)")
                                .bold()
                            
                            Text("Distance")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.blue)
                            Text("\(viewModel.distanceString)")
                                .bold()
                            
                        }
                    }
                    Spacer()
                    
                    ZStack {
                        ProgressCircleView(progress: $viewModel.calories, goal: 600, color: .red)
                        ProgressCircleView(progress: $viewModel.steps, goal: 10000, color: .green)
                            .padding(.all, 20)
                        ProgressCircleView(progress: $viewModel.distance, goal: 10, color: .blue)
                            .padding(.all, 40)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding()
                
                HStack {
                    Text("Activity")
                        .font(.title2)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if !viewModel.activities.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2)) {
                        ForEach(viewModel.activities, id: \.id) { activity in
                            ActivityCardView(activity: activity)
                        }
                    }
                    .padding(.horizontal)
                } 
            }
        }
        .refreshable {
            viewModel.refreshData()
            print("Refresh data")
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
