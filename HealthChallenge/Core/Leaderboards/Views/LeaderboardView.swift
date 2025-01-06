//
//  LeaderboardView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-02.
//

import SwiftUI

struct LeaderboardUser: Codable, Identifiable {
    let id: String
    let username: String
    let calories: Int
    let steps: Int
    let distance: Int
    let points: Int
}

struct LeaderboardView: View {
    @AppStorage("username") var username: String?
    @State var viewModel = LeaderboardViewModel()
    
    @Binding var showTermsOfService: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack {
                    Text("Leaderboard")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    HStack {
                        Text("Name")
                            .bold()
                        
                        Spacer()
                        
                        Text("Steps")
                            .bold()
                    }
                    .padding()
                    
                    // Break down the complex expression
                    let leaderboardEntries = Array(viewModel.leaderResult.top10.enumerated())
                    
                    LazyVStack(spacing: 22) {
                        ForEach(leaderboardEntries, id: \.1.id) { (index, person) in
                            HStack {
                                Text("\(index + 1).")
                                Text(person.username)
                                
                                if username == person.username {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(Color.theme.colorYellow)
                                }
                                
                                Spacer()
                                
                                Text("\(person.steps)") // Ensure this matches the leaderboard type
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if let user = viewModel.leaderResult.user {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color.theme.accent.opacity(0.2))
                        
                        HStack {
                            Text(user.username)
                            
                            Spacer()
                            
                            Text("\(user.steps)") // Ensure this matches the leaderboard type
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                if showTermsOfService {
                    Color.background
                    TermsView(showTerms: $showTermsOfService)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .alert("Ooops", isPresented: $viewModel.showAlert, actions: {
            Button(role: .cancel) {
                viewModel.showAlert = false
            } label: {
                Text("Ok")
            }
        }, message: {
            Text("There was an issue loading the leaderboard data, please try again")
        })
        .onChange(of: showTermsOfService) { _ in
            if !showTermsOfService && username != nil {
                viewModel.updateLeaderboard()
            }
        }
        .onAppear {
            viewModel.updateLeaderboard()
        }
        .refreshable {
            viewModel.updateLeaderboard()
        }
    }
}

#Preview {
    LeaderboardView(showTermsOfService: .constant(false))
}
