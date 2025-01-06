//
//  ChallengeManager.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import Foundation
import FirebaseFirestore

final class ChallengeManager {
    
    static let shared = ChallengeManager()
    private init() { }
    
    private let challengeCollection = Firestore.firestore().collection("challenges")
    private func challengeDocument(challengeId: String) -> DocumentReference {
        challengeCollection.document(challengeId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Notification
    private func sendLocalNotification(for challenge: Challenge) {
            let content = UNMutableNotificationContent()
            content.title = "New Daily Challenge!"
            content.body = challenge.title
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil // Trigger immediately
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error sending local notification: \(error)")
                }
            }
        }
    
    // MARK: - Listen for new Challenges
    func listenForNewChallenges() {
        Firestore.firestore().collection("challenges")
            .whereField("interval", isEqualTo: "d")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for challenges: \(error)")
                    return
                }
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let newChallenge = try? change.document.data(as: Challenge.self)
                        // Send a local notification or call FCM to notify users
                        print("New challenge added: \(String(describing: newChallenge?.title))")
                    }
                }
            }
    }
    
    // MARK: - Add New Challenge
    func addChallenge(
            title: String,
            description: String,
            points: Int,
            type: String,
            interval: String
        ) async throws {
            let newChallenge = Challenge(
                id: UUID().uuidString,
                title: title,
                description: description,
                points: points,
                type: type,
                interval: interval
            )
            try challengeCollection.document(newChallenge.id).setData(from: newChallenge)
    }
    
    // MARK: - Fetch Challenges
    func getChallenges(interval: String) async throws -> [Challenge] {
        let querySnapshot = try await challengeCollection
            .whereField("interval", isEqualTo: interval)
            .getDocuments()
        
        return try querySnapshot.documents.compactMap { doc in
            try doc.data(as: Challenge.self)
        }
    }
    
    // MARK: - Assign Challenge to User
    func assignChallengeToUser(userId: String, challengeId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        let challenge = try await challengeDocument(challengeId: challengeId).getDocument(as: Challenge.self)
        
        let data: [String: Any] = [
            "favouriteChallenge": [
                "id": challenge.id,
                "title": challenge.title,
                "description": challenge.description,
                "points": challenge.points,
                "type": challenge.type,
                "interval": challenge.interval,
            ]
        ]
        try await userRef.updateData(data)
    }
    
    // MARK: - Complete Challenge
    func completeChallenge(userId: String, challengeId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        // Add challenge to completedChallenges array
        let data: [String: Any] = [
            "completedChallenges": FieldValue.arrayUnion([challengeId])
        ]
        try await userRef.updateData(data)
    }
}

// MARK: Default challenges
extension ChallengeManager {
    func addDefaultChallenges() async {
        let existingChallenges = try? await challengeCollection.getDocuments()
        if let existingChallenges = existingChallenges, !existingChallenges.isEmpty {
            print("Challenges already exist.")
            return
        }

        let defaultChallenges = [
            Challenge(
                id: UUID().uuidString,
                title: "10,000!",
                description: "Take 10,000 steps today!",
                points: 10,
                type: "Steps",
                interval:"Daily"
            ),
            Challenge(
                id: UUID().uuidString,
                title: "10 km",
                description: "Walk 10 kilometers steps today!",
                points: 10,
                type: "Distance",
                interval:"Daily"
            ),
            Challenge(
                id: UUID().uuidString,
                title: "Burn 10",
                description: "Burn 10 active calories today!",
                points: 10,
                type: "Distance",
                interval:"Daily"
            )
        ]

        for challenge in defaultChallenges {
            try? challengeCollection.document(challenge.id).setData(from: challenge)
        }

        print("Default challenges added.")
    }
}
