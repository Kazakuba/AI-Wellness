//
//  AboutUsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        List {
            Section(header: Text("About Team")) {
                SettingsRow(icon: "person.crop.circle", title: "About Filip", color: .green)
                SettingsRow(icon: "person.crop.circle", title: "About Lucija", color: .teal)
                SettingsRow(icon: "person.crop.circle", title: "About Mišo", color: .indigo)
            }
            
            Section(header: Text("Social media links")) {
                SettingsRow(icon: "cat", title: "GitHub", color: .yellow)
            }
        }
        .navigationTitle("About us")
    }
}

#Preview {
    AboutUsView()
}
