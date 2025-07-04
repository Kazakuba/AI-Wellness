//
//  AppInfoView.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

struct AppInfoView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var body: some View {
        List {
            Section(header: Text("App Info").foregroundColor(isDarkMode ? .white : .black)) {
                Text("Version 1.0.0")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Text("Build 100")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
            }
        }
        .navigationTitle("App Info")
        .background(AppBackgroundGradient.main(isDarkMode))
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
