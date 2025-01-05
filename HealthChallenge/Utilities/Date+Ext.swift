//
//  Date+Ext.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-03.
//

import Foundation

extension Date {
    static func startOfDay(for date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2      // Start fetching on monday
        return calendar.date(from: components) ?? Date()
    }
    func fetchMonthStartAndEndDate() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var startDateComponent = calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self))
        let startDate = calendar.date(from: startDateComponent) ?? self
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day:-1), to: startDate) ?? self
        return (startDate,endDate)
    }
    
    func fetchPreviousMonday() -> Date {
        var calendar = Calendar.current

        calendar.firstWeekday = 2

        let weekday = calendar.component(.weekday, from: self)

        let daysToSubtract = weekday == 1 ? 6 : weekday - 2
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self) ?? Date()
    }
    
    func mondayDateFormat() -> String {
        let monday = self.fetchPreviousMonday()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: monday)
    }
}


