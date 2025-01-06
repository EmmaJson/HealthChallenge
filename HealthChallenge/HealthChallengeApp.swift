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
    @AppStorage("username") var username: String?
    @AppStorage("avatar") var avatar: String?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @State private var showSignInView: Bool = false
    @State private var showLaunchView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                //MARK: NAVSTACK-
                NavigationStack {
                    HomeTabView(showSignInView: $showSignInView)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                NavigationLink {
                                    ProfileView(showSignInView: $showSignInView)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accent)
                                            .frame(width: 26, height: 26)
                                        
                                        Image(avatar ?? "no avatar")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .clipShape(Circle())
                                    }
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
                        .task {
                            if !showSignInView {
                                await fetchProfile()
                            }
                        }
                }
                
                //MARK: NAVSTACK end-
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                            .animation(.easeInOut(duration: 0.6), value: showLaunchView)
                    }
                }
                .zIndex(2.0)
            }
        }
    }
    
    func fetchProfile() async {
        let userId = AuthenticationManager.shared.getAuthenticatedUserId()
        do {
            if let profile = try await UserManager.shared.getUserProfile(userId: userId) {
                print("Profile fetched: \(profile)")
                DispatchQueue.main.async {
                    username = profile.username
                    avatar = profile.avatar
                }
            } else {
                print("No profile data found for user \(userId)")
            }
        } catch {
            print("Failed to fetch profile: \(error.localizedDescription)")
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
