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
       
        _ = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: .didReceiveAffirmationNotification, object: nil)
        
        completionHandler()
    }
    func application(_ app: UIApplication, open url: URL, options option: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct AiWellnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isDarkMode") private var isDarkMode = false

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundEffect = nil
        tabBarAppearance.backgroundColor = .clear
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.6)


        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(SettingsViewModel(authService: AuthenticationService()))
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
