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
                    
                    Button {
                        withAnimation {
                            viewModel.toggleEditor()
                        }
                    } label: {
                        ZStack {
                            if !viewModel.isGoalsSet() {
                                Text("[ Tap to set goals ]")
                                    .font(.title)
                                    .bold()
                                ProgressCircleView(progress: $viewModel.calories, goal: 1000, color: .red)
                                ProgressCircleView(progress: $viewModel.steps, goal: 1000000, color: .green)
                                    .padding(.all, 20)
                                ProgressCircleView(progress: $viewModel.distance, goal: 10000, color: .blue)
                                    .padding(.all, 40)
                            } else {
                                ProgressCircleView(progress: $viewModel.calories, goal: Int(viewModel.calorieGoal), color: .red)
                                ProgressCircleView(progress: $viewModel.steps, goal: Int(viewModel.stepGoal), color: .green)
                                    .padding(.all, 20)
                                ProgressCircleView(progress: $viewModel.distance, goal: Int(viewModel.distanceGoal), color: .blue)
                                    .padding(.all, 40)
                            }
                        }
                        .padding(.leading)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                if viewModel.showEditGoal {
                    
                    VStack {
                        Text("Edit your goals")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        VStack {
                            SliderView(title: "Calories Goal: ", unit: "kcal" , sliderValue: $viewModel.currentCalorieGoal, start: 100, stop: 2000, color: .red)
                            
                            SliderView(title: "Step Goal: ", unit: "" , sliderValue: $viewModel.currentStepGoal, start: 1000, stop: 20000, color: .green)
                            
                            SliderView(title: "Distance Goal: ", unit: "km" , sliderValue: $viewModel.currentDistanceGoal, start: 1, stop: 20, color: .blue)
                        }
                        .padding()
                        
                        HStack {
                            ProfileItemButton(title: "Cancel", color: Color.accent.opacity(0.5)) {
                                withAnimation {
                                    viewModel.toggleEditor()
                                }
                            }
                            ProfileItemButton(title: "Save changes", color: Color.colorBlue) {
                                withAnimation {
                                    viewModel.setCurrentGoals()
                                    viewModel.toggleEditor()
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGray6)
                        .cornerRadius(15))
                    .padding()
                }
                
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
