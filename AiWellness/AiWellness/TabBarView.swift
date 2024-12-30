//
//  ContentView.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "square.split.2x2")
                    Text("Dashboard")
                }
            
            AiChat()
                .tabItem {
                    Image(systemName: "person.bubble")
                    Text("AI Chat")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Journal")
                }
        }
        .accentColor(.blue)
        
    }
}

#Preview {
    TabBarView()
}
