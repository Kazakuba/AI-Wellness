//
//  ContentView.swift
//  AiWellness
//
//  Created by Kazakuba on 23.12.24..
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        VStack {
            TabView {
                Group {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "square.split.2x2")
                            Text("Dashboard")
                        }
                    DashboardView()
                        .tabItem{
                            Image(systemName: "person.bubble")
                            Text("AI chat")
                                .foregroundColor(.white)

                        }
                    DashboardView()
                        .tabItem{
                            Image(systemName:"note.text")
                            Text("Journal")
                                .foregroundColor(.white)
                                
                        }
                }
                .toolbarBackground(.black, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .navigationBarBackButtonHidden(true)
            
        }

    }
}

#Preview {
    TabBarView()
}
