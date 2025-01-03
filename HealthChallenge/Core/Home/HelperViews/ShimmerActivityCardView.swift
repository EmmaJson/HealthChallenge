//
//  ShimmerActivityCardView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import SwiftUI

struct ShimmerActivityCardView: View {
    @State private var shimmerOffset: CGFloat = -200.0

    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)

            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        // Placeholder for title
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 100, height: 16)

                        // Placeholder for subtitle
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 80, height: 12)
                    }

                    Spacer()

                    // Placeholder for image
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 24, height: 24)
                }

                // Placeholder for amount
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 120, height: 24)
                    .padding()
            }
            .padding()
        }
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0), .white.opacity(0.6), .white.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 200)
            .rotationEffect(.degrees(30))
            .offset(x: shimmerOffset)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 400 // Adjust shimmer distance
                }
            }
        )
    }
}

#Preview {
    ShimmerActivityCardView()
}
