//
//  AiWellnessApp.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI
import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
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
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.unselectedItemTintColor = UIColor.white
        tabBarAppearance.tintColor = UIColor.white
        tabBarAppearance.backgroundColor = UIColor(white: 1, alpha: 0.15)
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(SettingsViewModel(authService: AuthenticationService()))  // Share ViewModel across views
                .preferredColorScheme(isDarkMode ? .dark : .light)  // Apply globally
        }
    }
}
