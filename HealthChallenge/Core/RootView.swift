//
//  HomeView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI


struct RootView: View {
    @Binding var showSignInView: Bool

    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    HomeView()
                }
            }
        }

        .onAppear {
            ChallengeManager.shared.listenForNewChallenges()
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView(showSignInView: .constant(false))
}
