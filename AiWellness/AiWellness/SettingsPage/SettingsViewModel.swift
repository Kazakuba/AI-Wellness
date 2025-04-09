//
//  SettingsViewModel.swift
//  AiWellness
//
//  Created by Lucija Iglič on 9. 2. 25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    @ObservedObject var authService = AuthenticationService()
    @Published var user: User?
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    
    @Published var isDarkMode: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var selectedAIVoice: String = "Filip"
    @Published var selectedLanguage: String = "English"
    @Published var selectedAppIcon: String = "Default"
    @Published var enableMotionEffects: Bool = true
    @Published var enableAffirmationAnimations: Bool = true
    
    let appIcons = ["Default", "Dark", "Light"]
    let aiVoice = ["Filip","Lucija","Miso"]
    let languages = ["English", "Spanish"]
    
    
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
