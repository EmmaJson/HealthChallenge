//
//  SliderView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-05.
//

import SwiftUI

struct SliderView: View {
    @State var title: String
    @State var unit: String
    @Binding var sliderValue: Double
    @State var start: Double
    @State var stop: Double
    @State var steps: Double
    @State var color: Color
    
    var body: some View {
        Text("\(title): \(Int(sliderValue)) \(unit)")
            .font(.footnote)
        Slider(value: $sliderValue, in: start...stop, step: steps)
            .padding()
            .accentColor(color)
    }
}
