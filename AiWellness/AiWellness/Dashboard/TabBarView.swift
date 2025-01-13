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

    var body: some View {
        TabView (selection: $selectedTab){
            DashboardView(authService: authService)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(0)
            AiChat()
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
        }
        .accentColor(.blue)

    }
}

//#Preview {
//    TabBarView(authService: authService)
//}
