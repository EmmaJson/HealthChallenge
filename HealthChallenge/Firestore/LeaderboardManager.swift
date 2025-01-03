//
//  LeaderboardManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-02.
//

import Foundation
import FirebaseFirestore

class LeaderboardManager {
    static let sharded = LeaderboardManager()
    private init() {}
    
    private let leaderboardDb = Firestore.firestore()
    private let weeklyLeaderboard = "\(Date().mondayDateFormat())-leaderboard"
    
    func fetchLeaderboards() async throws -> [LeaderboardUser] {
        let snapshot = try await leaderboardDb.collection(weeklyLeaderboard).getDocuments()
        return try snapshot.documents.compactMap({ try $0.data(as: LeaderboardUser.self)})
    }
    
    func postStepCountUpdateForUser(leader: LeaderboardUser) async throws {
        let data = try Firestore.Encoder().encode(leader)
        try await leaderboardDb.collection(weeklyLeaderboard).document(leader.id).setData(data, merge: false)
    }
}
