//
//  AppRootView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 7. 1. 25.
//

import SwiftUI
import FirebaseAuth

struct AppRootView: View {
    @StateObject var authService = AuthenticationService() // Shared service
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabBarView(authService: authService)
            } else {
                AuthenticationView(viewModel: .init(autheticationService: authService))
            }
        }
        .environmentObject(authService)
        .onAppear {
            checkAuthStatus()
            // Remove tab bar background so theme is visible on the whole screen
            let tabBarAppearance = UITabBar.appearance()
            tabBarAppearance.unselectedItemTintColor = UIColor.white
            tabBarAppearance.tintColor = UIColor.white
            tabBarAppearance.backgroundImage = UIImage()
            tabBarAppearance.shadowImage = UIImage()
            tabBarAppearance.backgroundColor = .clear
            tabBarAppearance.isTranslucent = true
        }
    }
    
    func checkAuthStatus() {
        // Check Firebase auth status
        if Auth.auth().currentUser != nil {
            authService.isAuthenticated = true
        }
    }
}

#Preview {
    AppRootView()
}
