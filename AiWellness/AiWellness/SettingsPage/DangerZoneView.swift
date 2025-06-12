//
//  DangerZoneView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct DangerZoneView: View {
    @State private var showDeleteChatsAlert = false
    @State private var showDeletedConfirmation = false
    @EnvironmentObject private var chatStore: ChatStore
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var body: some View {
        List {
            Section(header: Text("Danger Zone").foregroundColor(isDarkMode ? .white : .black)) {
                Button("Delete Account", role: .destructive) {
                    print("Delete Account")
                }
                .foregroundColor(isDarkMode ? .white : .black)
                Button("Delete All Chats", role: .destructive) {
                    showDeleteChatsAlert = true
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .alert(isPresented: $showDeleteChatsAlert) {
                    Alert(
                        title: Text("Delete All Chats"),
                        message: Text("Are you sure you want to delete all chats? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            chatStore.chats = []
                            chatStore.saveChatsToUserDefaults()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showDeletedConfirmation = true
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .alert("All chats deleted", isPresented: $showDeletedConfirmation) {
                    Button("OK", role: .cancel) {}
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
