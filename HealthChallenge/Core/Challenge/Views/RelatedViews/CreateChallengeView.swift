//
//  CreateChallengeView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var challengeType = "Distance" // Default challenge type
    @State private var interval = "Daily"
    @State private var errorMessage: String? = nil
    @State private var distanceOrStepsValue = 1 // Default value (e.g., 1 km or 1000 steps)

    let challengeTypes = ["Distance", "Steps", "Calories"]
    let intervals = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Challenge Type Picker
            Picker("Challenge Type", selection: $challengeType) {
                ForEach(challengeTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            // Conditional Input for Distance/Steps or Fixed Points
            if challengeType == "Distance" || challengeType == "Steps" {
                Stepper("\(distanceOrStepsValue) \(challengeType == "Distance" ? "km" : "000 steps")", value: $distanceOrStepsValue, in: 1...100)
            } else if challengeType == "Calories" {
                Stepper("\(distanceOrStepsValue)00 Kcal", value: $distanceOrStepsValue, in: 1...100)
            }
            
            Picker("Challenge Type", selection: $interval) {
                ForEach(intervals, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(Color.theme.colorRed)
            }

            Button("Create Challenge") {
                Task {
                    await createChallenge()
                    presentationMode.wrappedValue.dismiss()
                    presentAlert(title: "Success", message: "Challenge created successfully!")
                }
            }
            .padding()
            .background(Color.theme.colorBlue)
            .foregroundColor(Color.theme.primaryText)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Create Challenge")
    }


    private func createChallenge() async {
        guard !title.isEmpty, !description.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }

        // Calculate Points Based on Challenge Type
        let points: Int
        switch challengeType {
        case "Distance", "Steps":
            points = distanceOrStepsValue
        case "Calories":
            points = distanceOrStepsValue
        default:
            points = 0
        }

        do {
            try await ChallengeManager.shared.addChallenge(
                title: title,
                description: description,
                points: points,
                type: challengeType,
                interval: interval
            )
            errorMessage = nil
        } catch {
            errorMessage = "Failed to create challenge: \(error.localizedDescription)"
        }
    }
}
