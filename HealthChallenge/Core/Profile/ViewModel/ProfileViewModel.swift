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
    var welcomeMessage: String = "Good Morning"
    
    var authenticationProviders: [String] = []
    var completedChallenges: Int = 0
    var totalPoints: Int = 0
    
    var currentName = ""
    var profileName = UserDefaults.standard.string(forKey: "username") ?? "[Set a Name]"

    var selectedImage: String = UserDefaults.standard.string(forKey: "avatar") ?? ""
    var profileImage: String = UserDefaults.standard.string(forKey: "avatar") ?? "no avatar"
    
    var images = ["avatar 1", "avatar 2", "avatar 3", "avatar 4", "avatar 5", "avatar 6", "avatar 7", "avatar 8", "avatar 9", "avatar 10", "avatar 11", "avatar 12", "avatar 13", "avatar 14", "avatar 15", "avatar 16", "avatar 17", "avatar 18", "avatar 19", "avatar 20"
    ]
    
    init() {
        determineTimeOfDay()
        Task {
            await fetchProfile()
        }
    }
    
    func presentEditName() {
        currentName = ""
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
        currentName = ""
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
    
    func fetchProfile() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            if let profile = try await UserManager.shared.getUserProfile(userId: userId) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.profileName = profile.username
                    self.selectedImage = profile.avatar
                    self.profileImage = profile.avatar
                    
                    UserDefaults.standard.set(profile.username, forKey: "username")
                    UserDefaults.standard.set(profile.avatar, forKey: "avatar")
                    
                    self.getUsersProviders()
                }
            } else {
                print("No profile data found for user: \(userId)")
            }
        } catch {
            print("Failed to fetch profile data: \(error.localizedDescription)")
        }
    }
}

extension ProfileViewModel {
    private func getUsersProviders() {
        authenticationProviders.removeAll()
        do {
            let authProviders = try AuthenticationManager.shared.getProviders()
            for provider in authProviders {
                switch(provider) {
                case .email: authenticationProviders.append("Email")
                case .google: authenticationProviders.append("Google")
                }
            }
        } catch {
            Logger.error("Error getting providers: \(error)")
        }
    }
    
    func fetchUserStats() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            let stats = try await UserManager.shared.getUserStats(userId: userId)
            DispatchQueue.main.async { [weak self] in
                self?.completedChallenges = stats.completedChallenges
                self?.totalPoints = stats.totalPoints
            }
        } catch {
            print("Failed to fetch user stats: \(error.localizedDescription)")
        }
    }
}

extension ProfileViewModel {
    func determineTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            welcomeMessage = "Good Morning,"
        case 12..<17:
            welcomeMessage = "Good Day,"
        case 17..<21:
            welcomeMessage = "Good Evening,"
        default:
            welcomeMessage = "Good Night,"
        }
    }
}
