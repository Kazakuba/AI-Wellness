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
        .onAppear {
            checkAuthStatus()
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
