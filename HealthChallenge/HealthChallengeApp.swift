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
    @Environment(\.scenePhase) var scenePhase
    @State private var showSignInView: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeTabView(showSignInView: $showSignInView)
                    .toolbar {
                        /*
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Test Notification") {
                                scheduleTestNotification()
                            }
                        }
                         */
                        
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
                    .toolbarBackground(Color.background.opacity(0.1), for: .navigationBar)
                    .onChange(of: scenePhase) { newPhase in
                        switch newPhase {
                        case .background:
                            print("App moved to background.")
                        case .active:
                            print("App moved to foreground.")
                            let userId = Auth.auth().currentUser?.uid
                            if let userId = userId {
                                UserManager.shared.resumeListeners(for: userId)
                            }
                        default:
                            break
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
            trigger: nil
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
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured")
        
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permissions granted: \(granted)")
            }
        }
        
        application.registerForRemoteNotifications()
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        Messaging.messaging().delegate = self
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        print("Firestore offline persistence enabled.")
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Performing background fetch...")
        
        Task {
            do {
                if NetworkMonitor.shared.isConnected {
                    print("Network available. Fetching data...")
                    let userId = Auth.auth().currentUser?.uid
                    try await UserManager.shared.checkAndCompleteChallenges(userId: userId ?? "")
                    print("Background fetch completed.")
                    completionHandler(.newData)
                } else {
                    print("Network unavailable. Skipping fetch.")
                    completionHandler(.noData)
                }
            } catch {
                print("Background fetch failed: \(error)")
                completionHandler(.failed)
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received silent notification...")
        
        Task {
            do {
                let userId = Auth.auth().currentUser?.uid
                guard let userId = userId else {
                    completionHandler(.noData)
                    return
                }
                try await UserManager.shared.checkAndCompleteChallenges(userId: userId)
                print("Silent notification processed.")
                completionHandler(.newData)
            } catch {
                print("Failed to process silent notification: \(error)")
                completionHandler(.failed)
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, let userId = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                try await UserManager.shared.updateFCMToken(userId: userId, fcmToken: token)
                print("FCM token updated: \(token)")
            } catch {
                print("Failed to update FCM token: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
