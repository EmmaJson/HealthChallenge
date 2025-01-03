//
//  ActivityCard.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct ActivityCardView: View {
    @State var activity: ActivityCard
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(activity.title)
                      
                        Text(activity.subtitle)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(activity.tintColor)
                }
                Text(activity.amount)
                    .font(.title)
                    .bold()
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ActivityCardView(activity: ActivityCard(id: 0, title: "Distance Steps", subtitle: "Goal 10 000", image: "figure.walk", tintColor: Color.green, amount: "6121"))
}
