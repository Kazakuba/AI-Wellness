//
//  WelcomeScreen.swift
//  AiWellness
//
//  Created by Lucija Iglič on 27. 12. 24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import ConfettiSwiftUI
import Lottie

struct DashboardView: View {
    @ObservedObject var authService: AuthenticationService
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var notificationService = NotificationService()
    @State private var showTimeCapsuleAnimation: Bool = false
    @State private var showTimeCapsule: Bool = false
    @State private var showSettings: Bool = false
    @State private var showTestNotifictions = false
    @State private var showAffirmationHistory = false
    @State private var showTodayAffirmation = false
    @State private var todayAffirmation: Affirmation?
    @StateObject private var confettiManager = ConfettiManager.shared

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.indigo, Color.black] :

            [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]

            ),
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
                .padding(.top, 8)
                Spacer()
                VStack(spacing: 20) {
                    GamifiedDashboardHeaderView()
                    AchievementsHorizontalScrollView()
                    BadgesHorizontalScrollView()
                    Spacer()
                }
                WeeklyRecapView()
                    .padding(.bottom, 12)
            }
            // Lottie Animation Overlay
            if showTimeCapsuleAnimation {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack {
                    Spacer()
                    LottieView(animation: .named("timeCapsuleAnimation"))
                        .playing()
                        .frame(width: 300, height: 300)
                        .onAppear {
                            // Adjust the delay to match your animation's duration
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showTimeCapsuleAnimation = false
                                    showTimeCapsule = true
                                    GamificationManager.shared.incrementAchievement("hidden_time_capsule")
                                }
                            }
                        }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
            if !showTimeCapsuleAnimation && !showTimeCapsule {
                HapticManager.strongLongHaptic()
                showTimeCapsuleAnimation = true
            }
        }
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, confettis: confettiManager.confettis, colors: [.yellow, .green, .blue, .orange])
        .fullScreenCover(isPresented: $showTimeCapsule) {
            TimeCapsuleView(isPresented: $showTimeCapsule)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authService)
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

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
