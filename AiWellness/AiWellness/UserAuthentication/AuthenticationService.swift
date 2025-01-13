//
//  AuthenticationService.swift
//  AiWellness
//
//  Created by Lucija Iglič on 3. 1. 25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated: Bool = false

    func googleSignIn() {
        guard FirebaseApp.app()?.options.clientID != nil else {
            print("Failed to fetch client ID.")
            return
        }

        // Get the rootViewController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to access root view controller.")
            return
        }

        // Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Error during Google Sign-In: \(error.localizedDescription)")
                return
            }

            // Extract user token
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get Google user or tokens.")
                return
            }
            let accessToken = user.accessToken.tokenString

            // Authenticate with Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error as NSError? {
                    let errorMessage: String

                    // Map Firebase error codes to user-friendly messages
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

                    // Show an alert to the user
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

                    // Update authentication state
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }

    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        print("Google Sign Out")
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
//import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift
//
//struct ContentView: View {
//    var body: some View {
//        GoogleSignInButton {
//            // Handle sign-in action
//            GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { signInResult, error in
//                // Check for errors and handle the sign-in result
//            }
//        }
//        .frame(width: 200, height: 50)
//    }
//
//    // Helper function to get the root view controller
//    func getRootViewController() -> UIViewController {
//        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let root = screen.windows.first?.rootViewController else {
//            fatalError("Unable to find root view controller")
//        }
//        return root
//    }
//}
