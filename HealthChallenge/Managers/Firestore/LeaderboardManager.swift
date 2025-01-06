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
        print("[DEBUG] Fetching leaderboard from collection: \(weeklyLeaderboard)")
        let snapshot = try await leaderboardDb.collection(weeklyLeaderboard).getDocuments()
        print("[DEBUG] Snapshot contains \(snapshot.documents.count) documents.")

        // Log each document before decoding
        snapshot.documents.forEach { document in
            print("[DEBUG] Document data: \(document.data())")
        }

        // Attempt to decode documents
        return try snapshot.documents.compactMap { document in
            do {
                return try document.data(as: LeaderboardUser.self)
            } catch {
                print("[DEBUG] Failed to decode document: \(document.data()), Error: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func postStepCountUpdateForUser(leader: LeaderboardUser) async throws {
        let data = try Firestore.Encoder().encode(leader)
        try await leaderboardDb.collection(weeklyLeaderboard).document(leader.id).setData(data, merge: false)
    }
}
