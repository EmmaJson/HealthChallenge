//
//  ProfileView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-29.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Running", "Hiking", "Swimming"]
    private func preferenceIsSelected(text: String) -> Bool {
        return viewModel.user?.preferences?.contains(text) == true
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.white.opacity(0.2)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .padding()

                Text(UserDefaults.standard.string(forKey: "username") ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if UserDefaults.standard.string(forKey: "username") == nil {
                    Text("Anonymous")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()

        List {
            if let user = viewModel.user {
                Text("Email: \(user.email ?? "Anonymous")")
                Text("User ID: \(user.userId)")
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { string in
                            Button(string) {
                                if preferenceIsSelected(text: string) {
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    viewModel.addUserPreference(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .fixedSize()
                            .tint(preferenceIsSelected(text: string) ? .blue : .gray)
                        }
                    }
                }
                Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    if user.favouriteChallenge == nil {
                        viewModel.addFavouriteChallenge()
                    } else {
                        viewModel.removeFavouriteChallenge()
                    }
                } label: {
                    Text("Favourite Challenge: \(user.favouriteChallenge?.title ?? "")")
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationBarTitle("Profile")
    }
}


#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}

