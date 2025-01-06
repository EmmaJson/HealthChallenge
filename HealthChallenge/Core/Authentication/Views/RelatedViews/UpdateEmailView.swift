//
//  UpdatePasswordView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI

struct UpdateEmailView: View {
    
    @State private var viewModel = AuthenticationViewModel()
    @State private var pressedButton = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        VStack {
            TextField("New Email...", text: $viewModel.password)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
                .cornerRadius(10)
            
            Button{
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email updated")
                        pressedButton = true
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                        print(error)
                    }
                }
            } label: {
                Text("Update Email ")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .frame(height:55)
                    .frame(maxWidth: . infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            
            if pressedButton {
                Text("Email Updated!")
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
        .navigationTitle("Update Email")
    }
}

#Preview {
    NavigationStack {
        UpdateEmailView()
    }
}
