//
//  UserModel.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import Foundation

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
    let pastChallenges: [PastChallenge]?
    let points: Int?
    
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
        self.pastChallenges = []
        self.points = 0
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
        activeChallenges: [ActiveChallenge]? = nil,
        pastChallenges: [PastChallenge]? = nil,
        points: Int?
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
        self.pastChallenges = pastChallenges
        self.points = points
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
        case activeChallenges       =   "active_challenges"
        case pastChallenges         =   "past_challenges"
        case points                 =   "points"
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
        self.pastChallenges = try container.decodeIfPresent([PastChallenge].self, forKey: .pastChallenges)
        self.points = try container.decodeIfPresent(Int.self, forKey: .points)
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
        try container.encodeIfPresent(self.pastChallenges, forKey: .pastChallenges)
        try container.encodeIfPresent(self.points, forKey: .points)
    }
}
