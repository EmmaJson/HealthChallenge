//
//  ProfileItemButton.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-04.
//

import SwiftUI

struct ProfileItemButton: View {
    @State var title: String
    @State var color: Color
    var action: (() -> Void)
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(title)
                .padding()
                .bold()
                .frame(maxWidth: 200)
                .foregroundColor(Color.white)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                )
        }
    }
}

#Preview {
    ProfileItemButton(title: "Test", color: .blue) {}
}
