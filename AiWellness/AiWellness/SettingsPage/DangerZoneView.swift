//
//  DangerZoneView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI
import FirebaseAuth

struct DangerZoneView: View {
    @State private var showDeleteChatsAlert = false
    @State private var showDeletedConfirmation = false
    @State private var showDeleteAccountAlert1 = false
    @State private var showDeleteAccountAlert2 = false
    @State private var showDeleteJournalsAlert = false
    @State private var showJournalsDeletedConfirmation = false
    @EnvironmentObject private var chatStore: ChatStore
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List {
            Section(header: Text("Danger Zone").foregroundColor(isDarkMode ? .white : .black)) {
                Button("Delete Account", role: .destructive) {
                    showDeleteAccountAlert1 = true
                }
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                .alert("Are you sure? This cannot be undone.", isPresented: $showDeleteAccountAlert1) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) { showDeleteAccountAlert2 = true }
                }
                .alert("Are you 100% sure?", isPresented: $showDeleteAccountAlert2) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        // Sign out, delete data and go to login page
                        let uid = GamificationManager.shared.getUserUID()
                        Auth.auth().currentUser?.delete(completion: { _ in })
                        try? Auth.auth().signOut()
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        if let uid = uid {
                            let onboardingKey = "onboarding_completed_\(uid)"
                            UserDefaults.standard.removeObject(forKey: onboardingKey)
                        }
                        UserDefaults.standard.synchronize()
                        NotificationCenter.default.post(name: Notification.Name("UserDidLogout"), object: nil)
                        dismiss() // Dismiss DangerZoneView
                    }
                } message: {
                    Text("This will delete your account and all saved data.")
                }
                Button("Delete All Chats", role: .destructive) {
                    showDeleteChatsAlert = true
                }
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                .alert("Delete All Chats", isPresented: $showDeleteChatsAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        chatStore.chats = []
                        chatStore.saveChatsToUserDefaults()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showDeletedConfirmation = true
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete all chats? This action cannot be undone.")
                }
                .alert("All chats deleted", isPresented: $showDeletedConfirmation) {
                    Button("OK", role: .cancel) {}
                }
                Button("Delete All Journal Entries", role: .destructive) {
                    showDeleteJournalsAlert = true
                }
                .foregroundColor(isDarkMode ? .white : .red)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                .alert("Delete All Journal Entries?", isPresented: $showDeleteJournalsAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        WritingDataManager.shared.deleteAllEntries()
                        showJournalsDeletedConfirmation = true
                    }
                } message: {
                    Text("Are you sure you want to delete all your journal entries? This cannot be undone.")
                }
                .alert("All journal entries deleted", isPresented: $showJournalsDeletedConfirmation) {
                    Button("OK", role: .cancel) {}
                }
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
