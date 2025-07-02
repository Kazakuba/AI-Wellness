//
//  SettingsViewModel.swift
//  AiWellness
//
//  Created by Kazakuba on 9. 2. 25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    @ObservedObject var authService: AuthenticationService
    @Published var user: User?
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var selectedAIVoice: String = "Filip"
    @Published var selectedAppIcon: String = "Default"
    @Published var enableMotionEffects: Bool = true
    @Published var enableAffirmationAnimations: Bool = true

    init(authService: AuthenticationService = AuthenticationService()) {
        self.authService = authService
    }
    
    func fetchUser() {
        guard let firebaseUser = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.user = nil
            }
            return
        }

        let fetchedUser = User(
            profileImageURL: firebaseUser.photoURL?.absoluteString,
            name: firebaseUser.displayName ?? "Unknown User",
            email: firebaseUser.email ?? "Unknown Email"
        )

        DispatchQueue.main.async {
            self.user = fetchedUser
        }
    }
    
    
    func googleSignOut() {
        authService.googleSignOut()
        isLoggedIn = false
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}
