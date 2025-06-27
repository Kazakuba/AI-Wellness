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
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Button("Delete All Chats", role: .destructive) {
                    showDeleteChatsAlert = true
                }
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                .alert(isPresented: $showDeleteChatsAlert) {
                    Alert(
                        title: Text("Delete All Chats"),
                        message: Text("Are you sure you want to delete all chats? This action cannot be undone.").foregroundColor(isDarkMode ? .white : .black),
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
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
            }
        }
        .navigationTitle("Account Management")
        .background(isDarkMode ? Color.black : Color.white)
        .scrollContentBackground(.hidden)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .tint(isDarkMode ? .white : .black)
    }
}

#Preview {
    DangerZoneView()
}
