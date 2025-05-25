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
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var notificationService = NotificationService()
    @State private var showTimeCapsule: Bool = false
    @State private var showSettings: Bool = false
    @State private var showTestNotifictions = false
    @State private var showAffirmationHistory = false
    @State private var showTodayAffirmation = false
    @State private var todayAffirmation: Affirmation?

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            ExampleImage()
            VStack {
                HStack {
                    WelcomeText()
                    Spacer()
                    IconButton(icon: "gear.circle", title: "") {
                        withAnimation {
                            showSettings = true
                        }
                    }
                }
                .padding()
                Spacer()
                VStack {
                    PrimaryButton(title: "Open Time Capsule") {
                        withAnimation {
                            showTimeCapsule = true
                        }
                    }
                    PrimaryButton(title: "Test Notification") {
                        withAnimation {
                            showTestNotifictions = true
                        }
                    }
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showTimeCapsule) {
            TimeCapsuleView(isPresented: $showTimeCapsule)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authService)
        }
        .fullScreenCover(isPresented: $showTestNotifictions) {
            NotificationTestView(isPresented: $showTestNotifictions)
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
            .ignoresSafeArea()
            .opacity(0.9)
    }
}

#Preview {
    DashboardView(authService: AuthenticationService())
        .environmentObject(SettingsViewModel())
}
