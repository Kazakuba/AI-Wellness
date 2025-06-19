//
//  AiWellnessApp.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI
import Firebase
import GoogleSignIn
import UserNotifications
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        return true
    }
    //For handling taps on notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped by user")

        
        let userInfo = response.notification.request.content.userInfo

        if let base64 = userInfo["note"] as? String,
           let data = Data(base64Encoded: base64),
           let note = try? JSONDecoder().decode(TimeCapsuleNote.self, from: data) {
            print("Successfully decoded note: \(note.content)")

            
            NotificationCenter.default.post(
                name: .didTapTimeCapsuleNotification,
                object: note
            )
        } else {
            print("Failed to decode TimeCapsuleNote from notification userInfo")
        }

        completionHandler()
    }
    
    // Show notifications even when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])  // This forces it to appear
    }
    
    func application(_ app: UIApplication, open url: URL, options option: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct AiWellnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var appState = AppState()

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundEffect = nil
        tabBarAppearance.backgroundColor = .clear
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.6)

        // Set initial navigation bar tint color based on isDarkMode
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        UINavigationBar.appearance().tintColor = isDarkMode ? .white : .black

        // Listen for changes to isDarkMode and update navigation bar tint color
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { _ in
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            UINavigationBar.appearance().tintColor = isDarkMode ? .white : .black
        }

        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(SettingsViewModel(authService: AuthenticationService()))  // Share ViewModel across views
                .environmentObject(appState) // sharing with entire app
                .preferredColorScheme(isDarkMode ? .dark : .light)  // Apply globally
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge,.sound]) { granted, error in
            if granted {
                print("Permission granted.")
            } else {
                print("Permission denied.")
            }
        }
    }
}

extension Notification.Name {
    static let didTapTimeCapsuleNotification = Notification.Name("didTapTimeCapsuleNotification")
}
