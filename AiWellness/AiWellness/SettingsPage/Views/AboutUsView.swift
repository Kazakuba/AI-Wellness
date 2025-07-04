//
//  AboutUsView.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

struct AboutUsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var body: some View {
        List {
            Section(header: Text("About Team").foregroundColor(isDarkMode ? .white : .black)) {
                SettingsRow(icon: "person.crop.circle", title: "About Filip", color: .green)
                SettingsRow(icon: "person.crop.circle", title: "About Mišo", color: .indigo)
            }
            
            Section(header: Text("Social media links").foregroundColor(isDarkMode ? .white : .black)) {
                SettingsRow(icon: "cat", title: "GitHub", color: .yellow)
            }
        }
        .navigationTitle("About us")
        .background(AppBackgroundGradient.main(isDarkMode))
        .scrollContentBackground(.hidden)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .tint(isDarkMode ? .white : .black)
    }
}

#Preview {
    AboutUsView()
}
