//
//  TabView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct HomeTabView: View {
    @AppStorage("username") var username: String?
    @AppStorage("avatar") var avatar: String?
    @State var selectedTab = "Home"
    @Binding var showSignInView: Bool
    @State var showTermsView = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RootView(showSignInView: $showSignInView)
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            ChartView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Charts")
            }
            
            ChallengesView()
                .tag("Tasks")
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Tasks")
                }
            
            LeaderboardView(showTermsOfService: $showTermsView)
                .tag("Leaderboard")
                .tabItem {
                    Image(systemName: "medal.star")
                    Text("Leaderboard")
                }
        }
        .tint(.accent)
        .onAppear {
            showTermsView = username == nil
        }
        .task {
            await fetchProfile()
        }
    }
}

#Preview {
    HomeTabView(showSignInView: .constant(false))
}

extension HomeTabView {
    func fetchProfile() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            if let profile = try await UserManager.shared.getUserProfile(userId: userId) {
                DispatchQueue.main.async {
                    username = profile.username
                    avatar = profile.avatar
                }
            }
        } catch {
            print("Failed to fetch profile: \(error.localizedDescription)")
        }
    }
}
