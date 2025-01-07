//
//  SettingsView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI

struct SettingsView: View {
    let defaultURL = URL(string: "https://www.google.com")!
    let githubURL = URL(string: "https://github.com/EmmaJson/HealthChallenge")!
    let flaticonURL = URL(string: "https://www.flaticon.com/authors/roundicons")!
    
    @State private var viewModel = AuthenticationViewModel()
    @State var viewModel2 = ProfileViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List {
            appSection
            
            helpSection
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            anonymousSection
            
            Button(role: .cancel) {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign Out")
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete Account")
            }
        }
        .onAppear() {
            Task { await viewModel2.fetchProfile() }
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var appSection: some View {
        Section {
            VStack(alignment: .leading) {
                Image("appicon")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, 5)
                Text("This app was made by Emma, Lova and Julia (aka the team).")
                    .padding(.top)
            }
            Link("Check out the GitHub ", destination: githubURL)
            
        } header: {
            Text("Developers")
        }
    }
    
    private var helpSection: some View {
        Section {
            VStack(alignment: .leading) {
                Image("flaticon")
                    .resizable()
                    .padding(.top, 5)
                    .padding(.trailing)
                    .frame(height: 80)
                Text("The icons used in this app are free to download from Flaticon.")
                    .padding(.top)
            }
            Link("Check Flaticon out", destination: flaticonURL)
            
        } header: {
            Text("Flaticon")
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            NavigationLink(destination: UpdatePasswordView()) {
                Text("Change Password")
            }
            
            NavigationLink(destination: UpdateEmailView()) {
                Text("Change Email")
            }
        } header: {
            Text("Account")
        }
    }
}

extension SettingsView {
    private var anonymousSection: some View {
        Section {
            Button("Link Google") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED")
                    } catch {
                        print(error)
                    }
                }
            }
            
            NavigationLink(destination: LinkEmailView()) {
                Text("Link Email")
            }
            
        } header: {
            Text("Create account")
        }
    }
}
