//
//  SettingsView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List {
           
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
