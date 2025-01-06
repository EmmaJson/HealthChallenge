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
                                .foregroundColor(Color.theme.colorRed)
                            Text("\(viewModel.calories)")
                                .bold()
                            
                            Text("Steps")
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color.theme.colorGreen)
                            Text("\(viewModel.steps)")
                                .bold()
                            
                            Text("Distance")
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color.theme.colorBlue)
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
                                ProgressCircleView(progress: $viewModel.calories, goal: 1000, color: Color.theme.colorRed)
                                ProgressCircleView(progress: $viewModel.steps, goal: 1000000, color: Color.theme.colorGreen)
                                    .padding(.all, 20)
                                ProgressCircleView(progress: $viewModel.distance, goal: 10000, color: Color.theme.colorBlue)
                                    .padding(.all, 40)
                            } else {
                                ProgressCircleView(progress: $viewModel.calories, goal: Int(viewModel.calorieGoal), color: Color.theme.colorRed)
                                ProgressCircleView(progress: $viewModel.steps, goal: Int(viewModel.stepGoal), color: Color.theme.colorGreen)
                                    .padding(.all, 20)
                                ProgressCircleView(progress: $viewModel.distance, goal: Int(viewModel.distanceGoal), color: Color.theme.colorBlue)
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
                            SliderView(title: "Calories Goal: ", unit: "kcal" , sliderValue: $viewModel.currentCalorieGoal, start: 100, stop: 2000, color: Color.theme.colorRed)
                            
                            SliderView(title: "Step Goal: ", unit: "" , sliderValue: $viewModel.currentStepGoal, start: 1000, stop: 20000, color: Color.theme.colorGreen)
                            
                            SliderView(title: "Distance Goal: ", unit: "km" , sliderValue: $viewModel.currentDistanceGoal, start: 1, stop: 20, color: Color.theme.colorBlue)
                        }
                        .padding()
                        
                        HStack {
                            ProfileItemButton(title: "Cancel", color: Color.theme.accent.opacity(0.5)) {
                                withAnimation {
                                    viewModel.toggleEditor()
                                }
                            }
                            ProfileItemButton(title: "Save changes", color: Color.theme.colorBlue) {
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
                        .bold()
                    
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
                
                HStack {
                    Text("Active Challenges")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                if !viewModel.challenges.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 1)) {
                        ForEach(viewModel.challenges, id: \.challenge.challengeId) { challenge in
                            ChallengeCardView(challenge: challenge)
                        }
                    }
                    .padding(.bottom)
                } else {
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.8))
                            
                            Text("No Active Challenges")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.theme.secondaryText.opacity(0.8))
                            
                            Text("Join a challenge to get started!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.6))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.theme.secondaryText.opacity(0.1))
                                .shadow(radius: 5)
                        )
                        .padding()
                        
                        Spacer()
                    }
                }
             
                // MARK: Past Challenges-
                HStack {
                    Text("Past Challenges")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                if !viewModel.completedChallenges.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 1)) {
                        ForEach(viewModel.completedChallenges, id: \.finishedChallengeId) { pastChallenge in
                            ChallengeCardView(challenge: ChallengeCard(challenge: pastChallenge.challenge, image: "trophy.fill", tintColor: Color.theme.colorYellow))
                        }
                    }
                    .padding(.bottom)
                } else {
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.8))
                            
                            Text("No Finished Challenges")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.theme.secondaryText.opacity(0.8))
                            
                            Text("Join a challenge to get started!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.6))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.theme.secondaryText.opacity(0.1))
                                .shadow(radius: 5)
                        )
                        .padding()
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
            print("Refresh data")
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
