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
                    Text("Leaderboards")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    HStack {
                        Spacer()

                        Button {
                            withAnimation {
                                viewModel.moveLeft()
                            }
                        } label: {
                            ZStack {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color.theme.onBackground)
                                    .zIndex(2)
                                Circle()
                                    .frame(width: 34, height: 34)
                                    .background(Color.theme.background)
                                    .foregroundStyle(Color.theme.background)
                                    .clipShape(Circle.circle)
                                    .shadow(color: Color.theme.onBackground .opacity(0.5),radius: 5)
                                    .zIndex(1)
                            }
                        }
                        Spacer()
                        
                        Text(viewModel.leaderboardtype.rawValue.uppercased(with: .autoupdatingCurrent))
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewModel.moveRight()
                            }
                        } label: {
                            ZStack {
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color.theme.onBackground)
                                    .zIndex(2)
                                Circle()
                                    .frame(width: 34, height: 34)
                                    .background(Color.theme.background)
                                    .foregroundStyle(Color.theme.background)
                                    .clipShape(Circle.circle)
                                    .shadow(color: Color.theme.onBackground .opacity(0.5),radius: 5)
                                    .zIndex(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Name")
                            .bold()
                        
                        Spacer()
                        
                        Text("Count")
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
                                
                                switch viewModel.leaderboardtype {
                                case .points: Text("\(person.points)")
                                case .calories: Text("\(person.calories)")
                                case .steps: Text("\(person.steps)")
                                case .distance: Text("\(person.distance)")
                                }
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
                            
                            switch viewModel.leaderboardtype {
                            case .points: Text("\(user.points)")
                            case .calories: Text("\(user.calories)")
                            case .steps: Text("\(user.steps)")
                            case .distance: Text("\(user.distance)")
                            }
                        }
                        .padding(.horizontal)
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
