//
//  ProfileView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-29.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("profilePicture") var profilePicture: String?
    @AppStorage("profileName") var profileName: String?
    
    @State private var isEditingName = true
    @State private var currentName = ""
    @State private var isEditingProfilePicture = false
    @State private var selectedImage: String = "avatar 20"
    
    @State private var images = ["avatar 1", "avatar 2", "avatar 3", "avatar 4", "avatar 5", "avatar 6", "avatar 7", "avatar 8", "avatar 9", "avatar 10", "avatar 11", "avatar 12", "avatar 13", "avatar 14", "avatar 15", "avatar 16", "avatar 17", "avatar 18", "avatar 19", "avatar 20"
    ]

    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Running", "Hiking", "Swimming"]
    private func preferenceIsSelected(text: String) -> Bool {
        return viewModel.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(profilePicture ?? "avatar 20")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.all, 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            isEditingProfilePicture.toggle()
                        }
                    }
                
                VStack(alignment: .leading) {
                    Text("Good Morning, ")
                        .font(.largeTitle)
                        .foregroundColor(.accent)
                    
                    Text(profileName ?? "Anonymous")
                        .font(.title2)
                }
                Spacer()
            }
      
            VStack {
                
                ProfileEditButton(image: "square.and.pencil", title: "Edit Profile Picture") {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        isEditingName = false
                        isEditingProfilePicture.toggle()
                    }
                }
                
                if isEditingProfilePicture {
                    ProfilePictureEditor(selectedImage: $selectedImage, isEditing: $isEditingProfilePicture, images: images)
                        .transition(.scale)
                }
                
                
                ProfileEditButton(image: "square.and.pencil", title: "Edit Username") {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        isEditingProfilePicture = false
                        
                        isEditingName.toggle()
                    }
                }
                
                if isEditingName {
                    TextField("name", text: $currentName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    HStack {
                        Button {
                            withAnimation {
                                isEditingName = false
                            }
                        } label: {
                            Text("Return")
                                .padding()
                                .frame(maxWidth: 200)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.accent.opacity(0.5))
                                )
                        }
                        Button {
                            
                            if !currentName.isEmpty {
                                profileName = currentName
                                withAnimation {
                                    isEditingName = false
                                }
                            }
                            
                        } label: {
                            Text("Make changes")
                                .padding()
                                .frame(maxWidth: 200)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.colorBlue)
                                )
                        }
                    }
                    .padding()
                    .transition(.scale)
                }
                
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent.opacity(0.1))
            )
            
            VStack {
                ProfileEditButton(image: "envelope", title: "Contact Us") {
                    print("Button: contact")
                }
                ProfileEditButton(image: "text.document", title: "Privacy Policy") {
                    print("Button: privacy policy")
                }
                ProfileEditButton(image: "text.document", title: "Terms of Service") {
                    print("Button: terms of service")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent.opacity(0.1))
            )
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            selectedImage = profilePicture ?? "avatar 20"
        }
        
        /*
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
         */
        .navigationBarTitle("Profile")
    }
}


#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}

