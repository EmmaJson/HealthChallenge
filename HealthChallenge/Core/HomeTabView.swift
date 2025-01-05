//
//  TabView.swift
//  HealthChallenge
//
//  Created by Lova Thorén on 2024-12-31.
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
    }
}

#Preview {
    HomeTabView(showSignInView: .constant(false))
}
