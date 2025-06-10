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
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var notificationService = NotificationService()
    @State private var showTimeCapsule: Bool = false
    @State private var showSettings: Bool = false
    @State private var showTestNotifictions = false
    @State private var showAffirmationHistory = false
    @State private var showTodayAffirmation = false
    @State private var todayAffirmation: Affirmation?

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ? [Color.indigo, Color.black] : [Color.mint, Color.cyan]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()
            VStack {
                HStack {
                    WelcomeText(isDarkMode: isDarkMode)
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
                VStack(spacing: 20) {
                    GamifiedDashboardHeaderView()
                    // Achievements horizontal scroll
                    AchievementsHorizontalScrollView()
                    // Badges horizontal scroll
                    BadgesHorizontalScrollView()
                    // Weekly Recap collapsible
                    CollapsibleSectionView(title: "📆 Weekly Recap") {
                        WeeklyRecapView()
                    }
                    Spacer()
                }
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
    var isDarkMode: Bool = false
    @State var userName: String = "User"
    var body: some View {
        Text("Welcome \(userName)")
            .font(.title)
            .foregroundColor(isDarkMode ? .white : .black)
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

#Preview {
    DashboardView(authService: AuthenticationService())
        .environmentObject(SettingsViewModel())
}
