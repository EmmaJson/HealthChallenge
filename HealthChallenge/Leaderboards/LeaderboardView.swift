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
    let count: Int
}

struct LeaderboardView: View {
    @StateObject var viewModel = LeaderboardViewModel()
    @Binding var showTermsOfService: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
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
                
                LazyVStack(spacing: 22){
                    ForEach(Array(viewModel.leaderResult.top10.enumerated()), id: \.1.id) { (index, person) in
                        HStack {
                            Text("\(index + 1).")
                            Text(person.username)
                            
                            if viewModel.currentUsername == person.username {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer()
                            
                            Text("\(person.count)")
                        }
                        .padding(.horizontal)
                    }
                }
                
                if let user = viewModel.leaderResult.user {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    HStack {
                        Text(user.username)
                        
                        Spacer()
                        
                        Text("\(user.count)")
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .fullScreenCover(isPresented: $showTermsOfService) {
            TermsView()
        }
        .onAppear {
            Task {
                await viewModel.updateLeaderboard()
            }
        }
        
        .refreshable {
            viewModel.updateLeaderboard()
        }
        
    }
}

#Preview {
    LeaderboardView(showTermsOfService: .constant(false))
}
