import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var challengeType = "Distance" // Default challenge type
    @State private var interval = "Daily"
    @State private var errorMessage: String? = nil
    @State private var distanceOrStepsValue: Double = 1 // Default value (e.g., 1 km or 1000 steps)

    let challengeTypes = ["Distance", "Steps", "Calories"]
    let intervals = ["Daily", "Weekly", "Monthly"]

    // Dynamic Label for the Slider
    private var dynamicLabel: String {
        switch (challengeType, interval) {
        case ("Calories", "Daily"):
            return "\((Int(distanceOrStepsValue) * 100).formatted()) kcal"
        case ("Calories", "Weekly"):
            return "\((Int(distanceOrStepsValue) * 1000).formatted()) kcal"
        case ("Calories", "Monthly"):
            return "\((Int(distanceOrStepsValue) * 10_000).formatted()) kcal"
        case ("Distance", "Daily"):
            return "\(Int(distanceOrStepsValue)) km"
        case ("Distance", "Weekly"):
            return "\((Int(distanceOrStepsValue) * 10).formatted()) km"
        case ("Distance", "Monthly"):
            return "\((Int(distanceOrStepsValue) * 100).formatted()) km"
        case ("Steps", "Daily"):
            return "\((Int(distanceOrStepsValue) * 1_000).formatted()) steps"
        case ("Steps", "Weekly"):
            return "\((Int(distanceOrStepsValue) * 10_000).formatted()) steps"
        case ("Steps", "Monthly"):
            return "\((Int(distanceOrStepsValue) * 100_000).formatted()) steps"
        default:
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Challenge Type", selection: $challengeType) {
                ForEach(challengeTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker("Interval", selection: $interval) {
                ForEach(intervals, id: \.self) { interval in
                    Text(interval)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            VStack {
                Text(dynamicLabel)
                    .font(.headline)
                Slider(value: $distanceOrStepsValue, in: 1...40, step: 1)
                    .accentColor(.blue)
            }

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

        let points: Int
        switch (challengeType, interval) {
        case ("Calories", "Daily"):
            points = Int(distanceOrStepsValue)
        case ("Calories", "Weekly"):
            points = Int(distanceOrStepsValue)
        case ("Calories", "Monthly"):
            points = Int(distanceOrStepsValue)

        case ("Distance", "Daily"):
            points = Int(distanceOrStepsValue)
        case ("Distance", "Weekly"):
            points = Int(distanceOrStepsValue)
        case ("Distance", "Monthly"):
            points = Int(distanceOrStepsValue)

        case ("Steps", "Daily"):
            points = Int(distanceOrStepsValue)
        case ("Steps", "Weekly"):
            points = Int(distanceOrStepsValue)
        case ("Steps", "Monthly"):
            points = Int(distanceOrStepsValue)
        default: points = 0
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

#Preview {
    CreateChallengeView()
}
