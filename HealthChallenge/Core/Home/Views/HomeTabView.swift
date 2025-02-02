//
//  TabView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct HomeTabView: View {
    @AppStorage("username") var username: String?
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
            
            NutrientsView()
                .tag("Nutrients")
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrients")
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
            showTermsView = username == "[Set a Name]"
        }
    }
}

#Preview {
    HomeTabView(showSignInView: .constant(false))
}

