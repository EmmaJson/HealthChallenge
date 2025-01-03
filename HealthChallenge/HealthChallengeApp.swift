//
//  HealthChallengeApp.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-26.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

@main
struct HealthChallengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSignInView: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeTabView(showSignInView: $showSignInView)
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Test Notification") {
                                scheduleTestNotification()
                            }
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink {
                                ProfileView(showSignInView: $showSignInView) 
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.headline)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                SettingsView(showSignInView: $showSignInView)
                            } label: {
                                Image(systemName: "gear")
                                    .font(.headline)
                            }
                        }                 
                    }
            }
        }
    }
    private func scheduleTestNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification"
            content.body = "This is a test notification for the HealthChallenge app."
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil // Trigger immediately
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error sending test notification: \(error)")
                } else {
                    print("Test notification sent!")
                }
            }
    }
}
    
    class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            print("Firebase configured")
            
            // Request notification permissions
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
            
            application.registerForRemoteNotifications()
            Messaging.messaging().delegate = self
            
            
            return true
        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
        }
        
        // Handle FCM Token refresh
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            guard let token = fcmToken, let userId = Auth.auth().currentUser?.uid else { return }
            Task {
                do {
                    try await UserManager.shared.updateFCMToken(userId: userId, fcmToken: token)
                } catch {
                    print("Failed to update FCM token: \(error)")
                }
            }
        }
        
        
        // Handle foreground notifications
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
