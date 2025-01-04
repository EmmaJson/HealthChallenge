//
//  ProfileEditButton.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import SwiftUI

struct ProfileEditButton: View {
    @State var image: String
    @State var title: String
    var action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: image)
                Text(title)
            }
            .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProfileEditButton(image: "square.and.pencil", title: "Edit name") {
        print("Button: edit name")
    }
}
