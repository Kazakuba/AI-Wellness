//
//  AppInfoView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AppInfoView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var body: some View {
        List {
            Section(header: Text("App Info").foregroundColor(isDarkMode ? .white : .black)) {
                Text("Version 1.0.0")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color(.systemGray6))
                Text("Build 100")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color(.systemGray6))
            }
        }
        .navigationTitle("App Info")
        .background(isDarkMode ? Color.black : Color.white)
        .scrollContentBackground(.hidden)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .tint(isDarkMode ? .white : .black)
    }
}
#Preview {
    AppInfoView()
}
