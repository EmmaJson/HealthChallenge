//
//  ProfileViewModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    var showAlert = false
    var isEditingName = false
    var isEditingProfilePicture = false
    
    var currentName = ""
    var profileName = UserDefaults.standard.string(forKey: "username") ?? "Set a Name"

    var selectedImage: String = UserDefaults.standard.string(forKey: "avatar") ?? ""
    var profileImage: String = UserDefaults.standard.string(forKey: "avatar") ?? "avatar 20"
    
    var images = ["avatar 1", "avatar 2", "avatar 3", "avatar 4", "avatar 5", "avatar 6", "avatar 7", "avatar 8", "avatar 9", "avatar 10", "avatar 11", "avatar 12", "avatar 13", "avatar 14", "avatar 15", "avatar 16", "avatar 17", "avatar 18", "avatar 19", "avatar 20"
    ]
    
    func presentEditName() {
        isEditingProfilePicture = false
        isEditingName.toggle()
    }
    
    func presentEditImage() {
        isEditingName = false
        isEditingProfilePicture.toggle()
    }
    
    func dismissEdit() {
        isEditingName = false
        isEditingProfilePicture = false
    }
    
    func setNewName() {
        profileName = currentName
        UserDefaults.standard.set(currentName, forKey: "username")
        
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            await self.saveProfile()
        }
        
        self.dismissEdit()
    }
    
    func selectNewImage(image: String) {
        selectedImage = image
    }
    
    func setNewImage() {
        profileImage = selectedImage
        UserDefaults.standard.set(selectedImage, forKey: "avatar")
        
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            await self.saveProfile()
        }
        
        self.dismissEdit()
    }
    
    func presentEmail() {
        let emailSubject = "Health Challenge - Contact us"
        let emailTo = "emmamhm2@gmail.com"
        
        let encodingSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodingTo = emailTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(encodingTo)?subject=\(encodingSubject)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.showAlert = true
            }
        }
        
    }
}

extension ProfileViewModel {
    private func saveProfile() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        print("Saving profile\(profileName), avatar=\(profileImage)")
        do {
            try await UserManager.shared.updateUserProfile(
                userId: userId,
                username: profileName,
                avatar: profileImage
                
            )
            print("Goals saved profile!")
        } catch {
            print("Failed to save profile: \(error.localizedDescription)")
        }
    }
}
