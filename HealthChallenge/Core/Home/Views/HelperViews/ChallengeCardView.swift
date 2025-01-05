//
//  ChallengeCard.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct ChallengeCardView: View {
    @State var challenge: ChallengeCard
    
    var body: some View {
        HStack {
            Image(systemName: challenge.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(challenge.tintColor)
                .padding()
                .background(.gray.opacity(0.2))
                .cornerRadius(10)
            
            VStack(spacing: 16) {
                HStack {
                    Text(challenge.challenge.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(challenge.challenge.points) p")
                        .font(.headline)
                }
                
                HStack {
                    Text(challenge.challenge.description)
                        .font(.subheadline)

                    Spacer()
                    
                    Text(challenge.challenge.startDate, format: .dateTime.day().month())
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }
}
