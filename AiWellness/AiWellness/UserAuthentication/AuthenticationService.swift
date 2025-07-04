//
//  AuthenticationService.swift
//  AiWellness
//
//  Created by Kazakuba on 3. 1. 25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var user: User? {
        didSet {
            NotificationCenter.default.post(name: .journalUserDidChange, object: nil)
        }
    }
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        if let firebaseUser = Auth.auth().currentUser {
            self.user = User(
                profileImageURL: firebaseUser.photoURL?.absoluteString,
                name: firebaseUser.displayName ?? "Unknown User",
                email: firebaseUser.email ?? "No Email"
            )
            isAuthenticated = true
        } else {
            isAuthenticated = false
            user = nil
        }
    }

    func googleSignIn() {
        guard FirebaseApp.app()?.options.clientID != nil else {
            print("Failed to fetch client ID.")
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to access root view controller.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Error during Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get Google user or tokens.")
                return
            }
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error as NSError? {
                    let errorMessage: String

                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        switch errorCode {
                        case .networkError:
                            errorMessage = "Network error occurred. Please check your internet connection and try again."
                        case .userDisabled:
                            errorMessage = "This account has been disabled. Contact support for assistance."
                        case .invalidCredential:
                            errorMessage = "The provided credentials are invalid. Please try again."
                        case .wrongPassword:
                            errorMessage = "The password is incorrect. Please try again."
                        case .emailAlreadyInUse:
                            errorMessage = "This email is already associated with another account."
                        default:
                            errorMessage = "An unknown error occurred. Please try again later."
                        }
                    } else {
                        errorMessage = "An error occurred. Please try again."
                    }

                    print("Firebase authentication error: \(error.localizedDescription)")

                    DispatchQueue.main.async {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first {
                            let alert = UIAlertController(title: "Sign-In Failed", message: errorMessage, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            window.rootViewController?.present(alert, animated: true)
                        }
                    }
                } else {
                    print("Signed in with Google: \(authResult?.user.email ?? "No Email")")

                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        if let uid = authResult?.user.uid {
                            GamificationManager.shared.setUser(uid: uid)
                        }
                    }
                }
            }
            self.checkAuthentication()
        }
    }

    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        print("Google Sign Out")
        ChatStore.shared.chats = [] 
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}

struct User {
    var profileImageURL: String?
    var name: String
    var email: String
}

extension Notification.Name {
    static let journalUserDidChange = Notification.Name("journalUserDidChange")
}
