//
//  ContentView.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var authService: AuthenticationService
    @EnvironmentObject var appState: AppState
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedTab = 0
    @State private var tabBarHidden: Bool = false
    @State private var showBreathingExercise: Bool = false
    @State private var unlockedNote: TimeCapsuleNote? = nil

    init(authService: AuthenticationService) {
        self.authService = authService
        UITabBar.appearance().backgroundColor = .clear
        UITabBar.appearance().barTintColor = .clear
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }

    var body: some View {
        VStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    DashboardView(authService: authService, isDarkMode: isDarkMode)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .tag(0)

                    ChatListView()
                        .tabItem {
                            Image(systemName: "person.bubble")
                            Text("AI Chat")
                        }
                        .tag(1)

                    CalendarView(selectedTab: $selectedTab, isDarkMode: isDarkMode)
                        .tabItem {
                            Image(systemName: "note.text")
                            Text("Journal")
                        }
                        .tag(2)

                    AffirmationsEntryView(isDarkMode: isDarkMode)
                        .tabItem {
                            Image(systemName: "sun.max.fill")
                            Text("Affirmations")
                        }
                        .tag(4)

                    BreathingEntryView(showBreathingExercise: $showBreathingExercise, isDarkMode: isDarkMode)
                        .tabItem {
                            Image(systemName: "lungs.fill")
                            Text("Breathe")
                        }
                        .tag(3)
                }
                .toolbarBackground(.hidden, for: .tabBar)
                .opacity(tabBarHidden ? 0 : 1)

                if showBreathingExercise {
                    BreathingExerciseView(tabBarHidden: $tabBarHidden)
                        .transition(.opacity)
                        .onDisappear {
                            selectedTab = 0
                        }
                }
            }
            Button(action: {
                if let uid = GamificationManager.shared.getUserUID() {
                    let key = "onboarding_completed_\(uid)"
                    UserDefaults.standard.removeObject(forKey: key)
                }
                NotificationCenter.default.post(name: Notification.Name("RestartOnboarding"), object: nil)
            }) {
                Text("Restart Onboarding (TEMP)")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showBreathingExercise = true
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissBreathingExercise"),
                                                  object: nil,
                                                  queue: .main) { _ in
                showBreathingExercise = false
                selectedTab = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didTapTimeCapsuleNotification)) { notification in
            
            print("Notification received")
            
            if let note = notification.object as? TimeCapsuleNote {
                print("Decoded note: \(note.content)")
                self.unlockedNote = note
                self.selectedTab = 0
            } else {
                print("Failed to decode TimeCapsuleNote")
            }
        }
        .sheet(item: $unlockedNote, onDismiss: {
            unlockedNote = nil
        }) { note in
            TimeCapsuleUnlockedView(note: note)
        }
    }
}

// ToFix
struct BreathingEntryView: View {
    @Binding var showBreathingExercise: Bool
    var isDarkMode: Bool = false
    
    var body: some View {
        VStack {
            Text("Loading breathing exercise...")
                .font(.title2)
                .foregroundColor(isDarkMode ? .white : Color(.secondaryLabel))
            ProgressView()
        }
        .background(
            (isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showBreathingExercise = true
            }
        }
    }
}

#Preview {
    TabBarView(authService: AuthenticationService())
}
