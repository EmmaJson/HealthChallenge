//
//  TermsView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-02.
//

import SwiftUI

struct TermsView: View {
    @AppStorage("username") var username: String?

    @Binding var showTerms: Bool
    
    @State var name = ""
    @State var acceptTerms = false

    var body: some View {
        VStack {
            Text("Accept the terms and conditions")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 10)
                        
            TextField("Displayed username...", text: $name)
                .padding()
                .background(Color.theme.accent.opacity(0.2))
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
                    username = name
                    showTerms = false
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
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
    TermsView(showTerms: .constant(true))
}
