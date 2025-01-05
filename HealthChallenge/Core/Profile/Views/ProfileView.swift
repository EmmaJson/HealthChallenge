//
//  ProfileView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-29.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        VStack {
            HStack {
                Image(viewModel.profileImage ?? "avatar 20")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.all, 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            viewModel.presentEditImage()
                        }
                    }
                
                VStack(alignment: .leading) {
                    Text("Good Morning, ")
                        .font(.title)
                        .foregroundColor(.accent)
                    
                    Text(viewModel.profileName ?? "Anonymous")
                        .font(.title2)
                }
                Spacer()
            }
      
            VStack {
                
                ProfileEditButton(image: "square.and.pencil", title: "Edit Profile Picture") {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        viewModel.presentEditImage()

                    }
                }
                
                if viewModel.isEditingProfilePicture {
                   
                    VStack(spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.images, id: \.self) { image in
                                    Button {
                                        withAnimation {
                                            viewModel.selectNewImage(image: image)
                                        }
                                    } label: {
                                        VStack {
                                            Image(image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                            if viewModel.selectedImage == image {
                                                Circle()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(Color.accentColor)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        HStack {
                            
                            ProfileItemButton(title: "Cancel", color: Color.accent.opacity(0.5)) {
                                withAnimation {
                                    viewModel.dismissEdit()
                                }
                            }.foregroundColor(Color.white)
                            
                            
                            ProfileItemButton(title: "Save changes", color: Color.colorBlue) {
                                withAnimation {
                                    viewModel.setNewImage()
                                }
                            }.foregroundColor(Color.white)
                        }
                    }
                    .transition(.scale)
                }
                
                
                ProfileEditButton(image: "square.and.pencil", title: "Edit Username") {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        viewModel.presentEditName()
                    }
                }
                
                if viewModel.isEditingName {
                    TextField("Name...", text: $viewModel.currentName)
                        .padding()
                        .foregroundColor(Color.gray)
                        .background()
                        .cornerRadius(10)
                        .padding(.horizontal)
                    HStack {
                        ProfileItemButton(title: "Cancel", color: Color.accent.opacity(0.5)) {
                            withAnimation {
                                viewModel.dismissEdit()
                            }
                        }.foregroundColor(Color.white)
                        
                        
                        ProfileItemButton(title: "Save changes", color: Color.colorBlue) {
                            if !viewModel.currentName.isEmpty {
                                withAnimation {
                                    viewModel.setNewName()
                                }
                            }
                        }.foregroundColor(Color.white)
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
                    viewModel.presentEmail()
                }
                
                Link(destination: URL(string: "https://github.com/EmmaJson/HealthChallenge/blob/main/Documents/HealthChallenge%20-%20Terms%20of%20Use.pdf")!) {
                    HStack {
                        Image(systemName: "text.document")
                        Text("Terms of Service")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Link(destination: URL(string: "https://github.com/EmmaJson/HealthChallenge/blob/main/Documents/HealthChallenge%20-%20Privacy%20Policy.pdf")!) {
                    HStack {
                        Image(systemName: "text.document")
                        Text("Privacy Policy")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent.opacity(0.1))
            )
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Ooops", isPresented: $viewModel.showAlert, actions: {
            Button(role: .cancel) {
                viewModel.showAlert = false
            } label: {
                Text("Ok")
            }
        }, message: {
            Text("We were unable to open your mail application")
        })
        .navigationBarTitle("Profile")
    }
}


#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
