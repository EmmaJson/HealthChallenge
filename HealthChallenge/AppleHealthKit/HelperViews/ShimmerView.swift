//
//  ShimmerView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import SwiftUI

struct ShimmerView: View {
    @State private var shimmerOffset: CGFloat = -200.0

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 20)
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
                        shimmerOffset = 400
                    }
                }
            )
    }
}
