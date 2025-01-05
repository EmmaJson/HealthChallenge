//
//  NetworkMonitor.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-05.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool = false
    var connectionType: NWInterface.InterfaceType?

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            self.connectionType = path.availableInterfaces.first?.type
            print("Network status changed. Connected: \(self.isConnected), Type: \(String(describing: self.connectionType))")
        }
        monitor.start(queue: queue)
    }
}
