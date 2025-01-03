//
//  ProgressCircleView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-31.
//

import SwiftUI

struct ProgressCircleView: View {
    @Binding var progress: Int
    var goal: Int
    private let width: CGFloat = 20
    var color: Color
    
    var body: some View {
        
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: width)
            Circle()
                .trim(from: 0, to: CGFloat(progress) / CGFloat(goal))
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round)).fill(color)
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
        }
        .padding()
    }
}

#Preview {
    ProgressCircleView(progress: .constant(100), goal: 200, color: .red)
}
