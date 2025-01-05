//
//  PresentAlert.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2025-01-05.
//

import SwiftUI

// MARK: Present alert from anywhere in the app
func presentAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok", style: .default)
    alert.addAction(ok)
    rootController?.present(alert, animated: true)
}

var rootController: UIViewController? {
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController {
        root = presenter
    }
    return root
}

