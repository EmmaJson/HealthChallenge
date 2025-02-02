//
//  SignUpView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI

struct SignUpEmailView: View {
    
    @State private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @State private var pressedButton = false
    @State private var errorMessage = false

    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
            
            Button{
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        pressedButton = true
                        errorMessage = false
                    } catch {
                        pressedButton = false
                        errorMessage = true
                        print(error)
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: . infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            
            if pressedButton {
                Text("Sign up Successful!")
                    .foregroundColor(Color.theme.colorGreen)
                    .font(.headline)
                    .padding(.bottom)
            }
            
            if errorMessage {
                Text("* Email has to be formatted xxxxx@xxxx.xxx \n* Password must be atleast 6 characters")
                    .foregroundColor(Color.theme.colorRed)
                    .font(.subheadline)
                    .padding(.bottom)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView(showSignInView: .constant(true))
    }
}
