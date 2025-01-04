//
//  Logger.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-04.
//

import Foundation

class Logger {
    static func log(_ message: String, level: String = "DEBUG") {
        print("[\(level)] \(message)")
    }

    static func error(_ message: String) {
        log(message, level: "ERROR")
    }

    static func info(_ message: String) {
        log(message, level: "INFO")
    }

    static func success(_ message: String) {
        log(message, level: "SUCCESS")
    }
}
