//
//  ProfilePictureEditor.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-04.
//

import SwiftUI

struct ProfilePictureEditor: View {
    @AppStorage("profilePicture") var profilePicture: String?

    @Binding var selectedImage: String
    @Binding var isEditing: Bool
    let images: [String]

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images, id: \.self) { image in
                        ProfileImageButton(
                            imageName: image,
                            isSelected: selectedImage == image,
                            onSelect: {
                                withAnimation {
                                    selectedImage = image
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                Button {
                    withAnimation {
                        isEditing = false
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
                    withAnimation {
                        profilePicture = selectedImage
                        isEditing = false
                    }
                } label: {
                    Text("Change Picture")
                        .padding()
                        .frame(maxWidth: 200)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.colorBlue)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accent.opacity(0))
        )
    }
}

// MARK: - ProfileImageButton Component

struct ProfileImageButton: View {
    let imageName: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.colorBlue : Color.clear, lineWidth: 4)
                )
                .shadow(color: isSelected ? Color.accentColor.opacity(0.5) : Color.clear, radius: 1.5)
                .padding(3)
        }
    }
}
