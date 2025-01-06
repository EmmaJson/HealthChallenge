//
//  ResetPasswordView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @State private var viewModel = AuthenticationViewModel()
    @State private var pressedButton = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
            
            Button{
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset link sent")
                        pressedButton = true
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                        print(error)
                    }
                }
            } label: {
                Text("Send reset link")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: . infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            
            if pressedButton {
                Text("Password Reset Link Sent!")
                    .foregroundColor(Color.theme.colorGreen)
                    .font(.headline)
                    .padding(.bottom)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(Color.theme.colorRed)
                    .font(.subheadline)
                    .padding(.bottom)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView()
    }
}
