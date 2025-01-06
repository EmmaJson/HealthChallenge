//
//  LaunchView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-06.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var loadingText: [String] = "Loading data...".map { String($0) }
    @State private var showLoadingText: Bool = false
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect() // Slower timing for smoother transition
    @State private var counter: Int = 0
    @State private var loops = 0
    @Binding var showLaunchView: Bool
    
    var body: some View {
        ZStack {
            Color.launchColorBackground
                .ignoresSafeArea()
            
            Image("unfilled accent")
                .resizable()
                .frame(width: 100, height: 100)
            
            ZStack {
                if showLoadingText {
                    HStack(spacing: 2) { // Adjust spacing for smoother flow
                        ForEach(loadingText.indices) { index in
                            Text(loadingText[index])
                                .font(.headline)
                                .foregroundColor(Color.launchAccent)
                                .fontWeight(.heavy)
                                .offset(y: counter == index ? -1.2 : 0)
                                .opacity(counter == index ? 1.0 : 0.8)
                        }
                    }
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5))) // Smoother scaling
                }
            }
            .offset(y: 80)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1)) {
                showLoadingText.toggle()
            }
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                let lastIndex = loadingText.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                    if loops == 3 {
                        withAnimation(.easeOut(duration: 1)) {
                            showLoadingText.toggle()
                        }
                    }
                    if loops >= 4 {
                        showLaunchView = false
                    }
                } else {
                    counter += 1
                }
            }
        })
    }
}

#Preview {
    LaunchView(showLaunchView: .constant(true))
}
