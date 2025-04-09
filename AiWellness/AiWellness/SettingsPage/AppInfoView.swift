//
//  AppInfoView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        List {
            Section(header: Text("Version Info")) {
                Text("App Version: 1.0.0")
                Text("Build: 1001")
            }
            
            Section(header: Text("Data & Security")) {
                Text("Data is securely stored and encrypted.")
            }
        }
        .navigationTitle("App Info")
    }
}
#Preview {
    AppInfoView()
}
