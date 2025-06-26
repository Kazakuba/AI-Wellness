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
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if showOnboarding {
                    OnboardingView {
                        showOnboarding = false
                    }
                } else {
                    TabBarView(authService: authService)
                }
            } else {
                AuthenticationView(viewModel: .init(autheticationService: authService))
            }
        }
        .environmentObject(authService)
        .onAppear {
            checkAuthStatus()
            if authService.isAuthenticated {
                showOnboarding = shouldShowOnboarding()
            }
            NotificationCenter.default.addObserver(forName: Notification.Name("RestartOnboarding"), object: nil, queue: .main) { _ in
                showOnboarding = true
            }
        }
    }
    
    func shouldShowOnboarding() -> Bool {
        guard let uid = GamificationManager.shared.getUserUID() else { return false }
        let key = "onboarding_completed_\(uid)"
        return !UserDefaults.standard.bool(forKey: key)
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
