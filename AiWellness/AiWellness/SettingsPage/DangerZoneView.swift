//
//  DangerZoneView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct DangerZoneView: View {
    var body: some View {
        List {
            Section(header: Text("Danger Zone")) {
                Button("Delete Account", role: .destructive) {
                    print("Delete Account")
                }
                Button("Delete All Chats", role: .destructive) {
                    print("Delete All Chats")
                }
                Button("Delete All Journal Entries", role: .destructive) {
                    print("Delete All Journal Entries")
                }
            }
        }
        .navigationTitle("Account Management")
    }
}

#Preview {
    DangerZoneView()
}
