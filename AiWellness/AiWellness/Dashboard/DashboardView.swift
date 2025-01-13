//
//  WelcomeScreen.swift
//  AiWellness
//
//  Created by Lucija Iglič on 27. 12. 24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct DashboardView: View {
    @ObservedObject var authService: AuthenticationService // Observing the  shared service

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            ExampleImage()
            VStack {
                HStack {
                    WelcomeText()
                    Spacer()

                    // Sign Out Button
                    AuthenticationSignOutButton(text: "Sign Out", action: authService.googleSignOut)
                }
                .padding()
                Spacer()
            }
        }
    }
}

private struct WelcomeText: View {
    @State var userName: String = "User"
    var body: some View {
        Text("Welcome \(userName)")
            .font(.title)
            .foregroundColor(.black)
            .onAppear {
                fetchUserName()
            }
    }
    
    func fetchUserName() {
        if let currentUser = Auth.auth().currentUser {
            // Firebase Auth user
            let fullName = currentUser.displayName ?? currentUser.email ?? "User"
            userName = extractFirstName(from: fullName).capitalized
        } else if let googleUser = GIDSignIn.sharedInstance.currentUser {
            // Google Sign-In user
            let fullName = googleUser.profile?.name ?? "User"
            userName = extractFirstName(from: fullName).capitalized
        } else {
            // Fallback
            userName = "User"
        }
    }

    func extractFirstName(from fullName: String) -> String {
        let components = fullName.split(separator: " ")
        return components.first.map { String($0) } ?? fullName
    }
}

private struct ExampleImage: View {
    var body: some View {
        Image("exampleImage")
            .resizable()
            .ignoresSafeArea(edges: .top)
            .opacity(0.9)
    }
}

#Preview {
    DashboardView(authService: AuthenticationService())
}
