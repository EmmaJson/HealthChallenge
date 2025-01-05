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
    
    //Profile
    let username: String?
    let avatar: String?
    
    //In progress
    let preferences: [String]?
    let favouriteChallenge: Challenge?
    
    //Goals
    let calorieGoal: Double?
    let stepGoal: Double?
    let distanceGoal: Double?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.dateCreated = Date()
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.username = nil
        self.avatar = nil
        self.preferences = nil
        self.favouriteChallenge = nil
        self.calorieGoal = 0
        self.stepGoal = 0
        self.distanceGoal = 0
    }
    
    init(
        userId: String,
        isAnonymous: Bool?,
        dateCreated: Date?,
        email: String?,
        photoURL: String?,
        username: String?,
        avatar: String?,
        preferences: [String]?,
        favouriteChallenge: Challenge? = nil,
        calorieGoal: Double?,
        stepGoal: Double?,
        distanceGoal: Double?
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.dateCreated = dateCreated
        self.email = email
        self.photoURL = photoURL
        self.username = username
        self.avatar = avatar
        self.preferences = preferences
        self.favouriteChallenge = favouriteChallenge
        self.calorieGoal = calorieGoal
        self.stepGoal = stepGoal
        self.distanceGoal = distanceGoal
    }
    
    enum CodingKeys: String, CodingKey {
        case userId                 =   "user_id"
        case isAnonymous            =   "is_anonymous"
        case dateCreated            =   "date_created"
        case email                  =   "email"
        case photoURL               =   "photo_url"
        case username               =   "username"
        case avatar                 =   "avatar"
        case preferences            =   "preferences"
        case favouriteChallenge     =   "favourite_challenge"
        case calorieGoal            =   "calorie_goal"
        case stepGoal               =   "step_goal"
        case distanceGoal           =   "distance_goal"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favouriteChallenge = try container.decodeIfPresent(Challenge.self, forKey: .favouriteChallenge)
        self.calorieGoal = try container.decodeIfPresent(Double.self, forKey: .calorieGoal)
        self.stepGoal = try container.decodeIfPresent(Double.self, forKey: .stepGoal)
        self.distanceGoal = try container.decodeIfPresent(Double.self, forKey: .distanceGoal)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.avatar, forKey: .avatar)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favouriteChallenge, forKey: .favouriteChallenge)
        try container.encodeIfPresent(self.calorieGoal, forKey: .calorieGoal)
        try container.encodeIfPresent(self.stepGoal, forKey: .stepGoal)
        try container.encodeIfPresent(self.distanceGoal, forKey: .distanceGoal)
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

// MARK: Goals
extension UserManager {
    func updateUserGoals(userId: String, calorieGoal: Double, stepGoal: Double, distanceGoal: Double) async throws {
        let data: [String: Any] = [
            DbUser.CodingKeys.calorieGoal.rawValue: calorieGoal,
            DbUser.CodingKeys.stepGoal.rawValue: stepGoal,
            DbUser.CodingKeys.distanceGoal.rawValue: distanceGoal
        ]
        print("Saving goals for user \(userId): \(data)") // Debugging
        try await userDocument(userId: userId).updateData(data)
    }
    
    
    func getUserGoals(userId: String) async throws -> (calorieGoal: Double, stepGoal: Double, distanceGoal: Double)? {
        let user = try await getUser(userId: userId)
        guard let calorieGoal = user.calorieGoal,
              let stepGoal = user.stepGoal,
              let distanceGoal = user.distanceGoal else {
            return nil
        }
        return (calorieGoal, stepGoal, distanceGoal)
    }
}

// MARK: Profile
extension UserManager {
    func updateUserProfile(userId: String, username: String, avatar: String) async throws {
        let data: [String: Any] = [
            DbUser.CodingKeys.username.rawValue: username,
            DbUser.CodingKeys.avatar.rawValue: avatar
        ]
        print("Saving goals for user \(userId): \(data)") // Debugging
        try await userDocument(userId: userId).updateData(data)
    }
    
    
    func getUserProfile(userId: String) async throws -> (username: String, avatar: String)? {
        let user = try await getUser(userId: userId)
        guard let username = user.username,
              let avatar = user.avatar else {
            return nil
        }
        return (username, avatar)
    }
}
