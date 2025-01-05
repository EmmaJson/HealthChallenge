//
//  UserManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-29.
//

import Foundation
import FirebaseFirestore

struct ActiveChallenge: Codable {
    let challengeId: String
    let title: String
    let startDate: Date
    let endDate: Date
}

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
    
    let activeChallenges: [ActiveChallenge]?
    
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
        self.activeChallenges = []
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
        distanceGoal: Double?,
        activeChallenges: [ActiveChallenge]? = nil
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
        self.activeChallenges = activeChallenges
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
        case activeChallenges      =   "active_challenges"
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
        self.activeChallenges = try container.decodeIfPresent([ActiveChallenge].self, forKey: .activeChallenges)
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
        try container.encodeIfPresent(self.activeChallenges, forKey: .activeChallenges)
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


extension UserManager {
    func joinChallenge(userId: String, challenge: Challenge) async throws {
        let startDate = Date()
        let endDate: Date
        
        switch challenge.interval {
        case "Daily":
            endDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .hour, value: 24, to: startDate)!)
        case "Weekly":
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        case "Monthly":
            endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate) ?? startDate
        default:
            print("Invalid challenge type: \(challenge.interval)") // Log the invalid type
            throw NSError(domain: "Invalid challenge type", code: 1, userInfo: nil)
        }
        
        let activeChallenge = ActiveChallenge(
            challengeId: challenge.id,
            title: challenge.title,
            startDate: startDate,
            endDate: endDate
        )
        
        // Update Firestore
        let data: [String: Any] = [
            "active_challenges": FieldValue.arrayUnion([try Firestore.Encoder().encode(activeChallenge)])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func unjoinChallenge(userId: String, challengeId: String) async throws {
        // Fetch the user's current active challenges
        let user = try await getUser(userId: userId)
        guard let activeChallenges = user.activeChallenges else {
            print("No active challenges to remove.")
            return
        }
        
        // Filter out the challenge with the matching challengeId
        let updatedChallenges = activeChallenges.filter { $0.challengeId != challengeId }
        
        // Encode the updated challenges array
        let encodedChallenges = try updatedChallenges.map { challenge in
            try Firestore.Encoder().encode(challenge)
        }
        
        // Update Firestore with the serialized array
        let data: [String: Any] = [
            "active_challenges": encodedChallenges
        ]
        try await userDocument(userId: userId).updateData(data)
    }
}
