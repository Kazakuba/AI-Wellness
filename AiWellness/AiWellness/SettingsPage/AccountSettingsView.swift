//
//  AccountSettingsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AccountSettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Account Settings")) {
                NavigationLink("Update Email / Password") {
                    Text("Email & Password Update Coming Soon")
                }
                NavigationLink("Link / Unlink Accounts") {
                    Text("Currently only Google Sign-In Available")
                }
            }
        }
        .navigationTitle("Account Management")
    }
}

#Preview {
    AccountSettingsView()
}
