//
//  TermsView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-02.
//

import SwiftUI

struct TermsView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State var name = ""
    @State var acceptTerms = false

    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 10)
                        
            TextField("Username", text: $viewModel.username)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                            
            HStack(alignment: .top) {
                Button {
                    withAnimation {
                        acceptTerms.toggle()
                    }
                } label: {
                    if acceptTerms {
                        Image(systemName: "checkmark.square.fill")
                    } else {
                        Image(systemName: "square")
                    }
                }
                Text("By checking this box, you agree to our terms and conditions")
            }
            .padding(.vertical)
            
            Button {
                if acceptTerms && name.count > 3 {
                    viewModel.updateUsername()
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.colorBlue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    TermsView()
}
