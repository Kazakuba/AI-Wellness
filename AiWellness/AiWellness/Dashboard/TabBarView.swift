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
                    DashboardView(authService: authService, isDarkMode: isDarkMode, isActiveTab: selectedTab == 0)
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

                    Color.clear
                        .tabItem {
                            Image(systemName: "lungs.fill")
                            Text("Breathe")
                        }
                        .tag(3)
                }
                .toolbarBackground(.hidden, for: .tabBar)
                .opacity(tabBarHidden ? 0 : 1)

                if selectedTab == 3 {
                    BreathingExerciseView(tabBarHidden: $tabBarHidden)
                        .transition(.opacity)
                        .onDisappear {
                            selectedTab = 0
                        }
                }
            }
            .accentColor(isDarkMode ? .white : Color("TextPrimary"))
            .background(Color("BackgroundRows").edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissBreathingExercise"),
                                                  object: nil,
                                                  queue: .main) { _ in
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

#Preview {
    TabBarView(authService: AuthenticationService())
}
