//
//  ChallengesView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct ChallengesView: View {
    @State private var viewModel = ChallengesViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Challenges...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(Color.theme.colorRed)
            } else if viewModel.challenges.isEmpty {
                Text("No challenges available.")
                    .foregroundColor(Color.theme.secondaryText)
            } else {
                List {
                    // Define the custom order
                    let intervals = ["Daily", "Weekly", "Monthly"]
                    
                    ForEach(intervals, id: \.self) { interval in
                        if let challengesForInterval = viewModel.groupedChallenges[interval] {
                            Section(header: Text(interval).font(.headline)) {
                                ForEach(challengesForInterval) { challenge in
                                    Button {
                                        Task {
                                            if viewModel.isChallengeActive(challenge.id) {
                                                await viewModel.unjoinChallenge(challenge)
                                            } else {
                                                await viewModel.joinChallenge(challenge)
                                            }
                                        }
                                    } label: {
                                        HStack(alignment: .center, spacing: 20) {
                                            if viewModel.isChallengeActive(challenge.id) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color.theme.colorGreen)
                                                    .font(.title3)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(Color.theme.secondaryText)
                                                    .font(.title3)
                                            }
                                            
                                            ZStack {
                                                VStack(alignment: .leading, spacing: 1) {
                                                    HStack(alignment: .center) {
                                                        VStack(alignment: .leading, spacing: 1) {
                                                            Text(challenge.title)
                                                                .font(.headline)
                                                                .fontWeight(.bold)
                                                            Text(challenge.description)
                                                                .font(.body)
                                                                .foregroundColor(Color.theme.secondaryText)
                                                                .padding(.top, 4)
                                                        }
                                                        
                                                        Spacer()
                                                        VStack(alignment: .center) {
                                                            Text("\(challenge.points) pts")
                                                                .font(.subheadline)
                                                                .foregroundColor(Color.theme.colorBlue)
                                                            Image(systemName: symbolForChallengeType(challenge.type))
                                                                .foregroundColor(.gray)
                                                                .font(.title3)
                                                                .padding(.top, 0.1)
                                                        }
                                                    }
                                                    

                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            NavigationLink(destination: CreateChallengeView()) {
                Text("Create a Challenge")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Challenges")
        .onAppear {
            Task {
                await viewModel.loadChallenges()
                await viewModel.fetchActiveChallenges()
            }
        }
    }
    
    private func symbolForChallengeType(_ type: String) -> String {
        switch type {
        case "Distance":
            return "figure.walk"
        case "Steps":
            return "shoeprints.fill"
        case "Calories":
            return "flame.fill"
        default:
            return "questionmark.circle"
        }
    }
}

#Preview {
    ChallengesView()
}
