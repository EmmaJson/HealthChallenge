//
//  AuthenticationView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @State private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
            Button("Sign in Anonymously") {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print("Error signing in Anonymously: \(error)")
                    }
                }
            }
            .font(.headline)
            .foregroundColor(Color.theme.primaryText)
            .frame(height:55)
            .frame(maxWidth: . infinity)
            .background(Color.orange)
            .cornerRadius(10)
        
            
            NavigationLink{
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with Email")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: . infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print("Error signing in with Google: \(error)")
                    }
                }
            } label: {
                HStack {
                    ZStack {
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .icon, state: .normal)) {
                            Task {
                                do {
                                    try await viewModel.signInGoogle()
                                    showSignInView = false
                                } catch {
                                    print("Error signing in with Google: \(error)")
                                }
                            }
                        }
                        .padding(.trailing, 200)
                        
                        ZStack {
                            Text("Log in with Google")
                                .font(.headline)
                                .foregroundColor(Color.theme.onBackground)
                        }
                    }
                }
                .frame(height:55)
                .frame(maxWidth: . infinity)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.theme.onBackground, lineWidth: 8)
                }
                .cornerRadius(10)
            }
            
            
            NavigationLink{
                SignUpEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Dont have an account?")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: . infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            
            NavigationLink{
                ResetPasswordView()
            } label: {
                Text("Forgot your password?")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent.opacity(0.4))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(true) )
    }
}
