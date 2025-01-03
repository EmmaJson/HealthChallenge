//
//  Double+Ext.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import Foundation

extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
