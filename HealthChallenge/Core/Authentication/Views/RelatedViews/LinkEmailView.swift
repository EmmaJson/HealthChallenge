//
//  LinkEmailView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import SwiftUI

struct LinkEmailView: View {
    @State private var viewModel = AuthenticationViewModel()
    @State private var pressedButton = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
            
            Button {
                Task {
                    guard !viewModel.email.isEmpty, !viewModel.password.isEmpty else {
                        errorMessage = "Email and password cannot be empty."
                        return
                    }
                    do {
                        try await viewModel.linkEmailAccount()
                        pressedButton = true
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                        print(error)
                    }
                }
            } label: {
                Text("Link Account")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            if pressedButton {
                Text("Email linked!")
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
        .navigationTitle("Link Email Account")
    }
}

#Preview {
    NavigationView {
        LinkEmailView()
    }
}
