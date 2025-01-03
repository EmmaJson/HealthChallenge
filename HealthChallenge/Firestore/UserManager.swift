//
//  UserManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-29.
//

import Foundation
import FirebaseFirestore

struct DbUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let dateCreated: Date?
    let email: String?
    let photoURL: String?
    let preferences: [String]?
    let favouriteChallenge: Challenge?
    let username: String?

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.dateCreated = Date()
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.preferences = nil
        self.favouriteChallenge = nil
        self.username = nil
    }
    
    init(
        userId: String,
        isAnonymous: Bool?,
        dateCreated: Date?,
        email: String?,
        photoURL: String?,
        preferences: [String]?,
        favouriteChallenge: Challenge? = nil,
        username: String?
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.dateCreated = dateCreated
        self.email = email
        self.photoURL = photoURL
        self.preferences = preferences
        self.favouriteChallenge = favouriteChallenge
        self.username = username
    }
    
    enum CodingKeys: String, CodingKey {
        case userId                 =   "user_id"
        case isAnonymous            =   "is_anonymous"
        case dateCreated            =   "date_created"
        case email                  =   "email"
        case photoURL               =   "photo_url"
        case preferences            =   "preferences"
        case favouriteChallenge     =   "favourite_challenge"
        case username               =   "username"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favouriteChallenge = try container.decodeIfPresent(Challenge.self, forKey: .favouriteChallenge)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favouriteChallenge, forKey: .favouriteChallenge)
        try container.encodeIfPresent(self.username, forKey: .username)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
            let encoder = Firestore.Encoder()
    //        encoder.keyEncodingStrategy = .convertToSnakeCase
            return encoder
        }()

        private let decoder: Firestore.Decoder = {
            let decoder = Firestore.Decoder()
    //        decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
    
    func updateUsername(userId: String, newUsername: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.updateData(["username": newUsername])
    }
    
    func createNewUser(user: DbUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> DbUser {
        try await userDocument(userId: userId).getDocument(as: DbUser.self)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DbUser.CodingKeys.preferences.rawValue: FieldValue.arrayUnion([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DbUser.CodingKeys.preferences.rawValue: FieldValue.arrayRemove([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addFavouriteChallenge(userId: String, challenge: Challenge) async throws {
        guard let data = try? encoder.encode(challenge) else {
            throw URLError(.badURL)
        }
        let dict: [String:Any] = [
            DbUser.CodingKeys.favouriteChallenge.rawValue : data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func removeFavouriteChallenge(userId: String) async throws {
        let data: [String:Any?] = [
            DbUser.CodingKeys.favouriteChallenge.rawValue : nil
        ]
        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
}

// MARK: NOTIFICATION
extension UserManager {
    func updateFCMToken(userId: String, fcmToken: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.updateData(["fcmToken": fcmToken])
    }
}
