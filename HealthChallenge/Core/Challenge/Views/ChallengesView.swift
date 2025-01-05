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
                    .foregroundColor(.red)
            } else if viewModel.challenges.isEmpty {
                Text("No challenges available.")
                    .foregroundColor(.gray)
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
                                        HStack(alignment: .center, spacing: 10) {
                                            if viewModel.isChallengeActive(challenge.id) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.title3)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                                    .font(.title3)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack {
                                                    Text(challenge.title)
                                                        .font(.headline)
                                                        .fontWeight(.bold)
                                                    Spacer()
                                                    Text("\(challenge.points) pts")
                                                        .font(.subheadline)
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                Text(challenge.description)
                                                    .font(.body)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 5)
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
                    .foregroundColor(.white)
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
            }
        }
    }
}
