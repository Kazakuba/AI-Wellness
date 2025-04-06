//
//  ContentView.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var authService: AuthenticationService // Shared service
    @State private var selectedTab = 0
    @State private var tabBarHidden: Bool = false
    @State private var showBreathingExercise: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView(authService: authService)
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
                
                CalendarView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "note.text")
                        Text("Journal")
                    }
                    .tag(2)
                
                // Breathing exercise trigger
                BreathingEntryView(showBreathingExercise: $showBreathingExercise)
                    .tabItem {
                        Image(systemName: "lungs.fill")
                        Text("Breathe")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
            // Hide the TabView's built-in tab bar when tabBarHidden is true
            .opacity(tabBarHidden ? 0 : 1)
            
            // Conditionally display the breathing exercise as a full screen cover
            if showBreathingExercise {
                BreathingExerciseView(tabBarHidden: $tabBarHidden)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onDisappear {
                        selectedTab = 0 // Go back to Dashboard tab
                    }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 3 {
                // When Breathing tab is selected, trigger the full screen exercise view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showBreathingExercise = true
                }
            }
        }
        .onAppear {
            // Listen for the dismiss notification from BreathingExerciseView
            NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissBreathingExercise"), 
                                                  object: nil, 
                                                  queue: .main) { _ in
                showBreathingExercise = false
                selectedTab = 0 // Return to Home tab
            }
        }
    }
}

// Simple view that just acts as an entry point for the breathing exercise
struct BreathingEntryView: View {
    @Binding var showBreathingExercise: Bool
    
    var body: some View {
        VStack {
            Text("Loading breathing exercise...")
                .font(.title2)
                .foregroundColor(.gray)
            ProgressView()
        }
        .onAppear {
            // Automatically show the breathing exercise when this tab is selected
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showBreathingExercise = true
            }
        }
    }
}

//#Preview {
//    TabBarView(authService: authService)
//}
