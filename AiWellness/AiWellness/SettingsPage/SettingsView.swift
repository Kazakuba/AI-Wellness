//
//  SettingsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 9. 2. 25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var authService: AuthenticationService
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    //@AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                if let user = viewModel.user, isMatch(searchText: searchText, text: user.name + " " + user.email) {
                    HStack {
                        AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                } else if searchText.isEmpty {
                    HStack {
                        AsyncImage(url: URL(string: viewModel.user?.profileImageURL ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(viewModel.user?.name ?? "Not logged in")
                                .font(.headline)
                            Text(viewModel.user?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Preferences
                Section(header: isMatch(searchText: searchText, text: "Preferences") ? Text("Preferences") : nil) {
                    if isMatch(searchText: searchText, text: "Color Scheme") {
                        SettingsRow(icon: "paintbrush.fill", title: "Color Scheme", color: .brown)
                    }
                    if isMatch(searchText: searchText, text: "App Icon " + viewModel.selectedAppIcon) {
                        PickerRow(icon: "paintpalette.fill", title: "App Icon", selection: $viewModel.selectedAppIcon, options: viewModel.appIcons, color: .orange)
                    }
                    if isMatch(searchText: searchText, text: "Dark Mode " + (viewModel.isDarkMode ? "On" : "Off")) {
                        ToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $viewModel.isDarkMode, color: .gray)
                    }
                    if isMatch(searchText: searchText, text: "Voice " + viewModel.selectedAIVoice) {
                        PickerRow(icon: "waveform", title: "Voice", selection: $viewModel.selectedAIVoice, options: viewModel.aiVoice, color: .cyan)
                    }
                }

                // Notifications
                Section(header: isMatch(searchText: searchText, text: "Notifications") ? Text("Notifications") : nil) {
                    if isMatch(searchText: searchText, text: "Enable Notifications " + (viewModel.notificationsEnabled ? "On" : "Off")) {
                        ToggleRow(icon: "bell.fill", title: "Enable Notifications", isOn: $viewModel.notificationsEnabled, color: .pink)
                    }
                    if viewModel.notificationsEnabled && isMatch(searchText: searchText, text: "Manage Specific Notifications") {
                        NavigationLink("Manage Specific Notifications") {
                            Text("Notification Preferences Coming Soon")
                        }
                    }
                }

                // Language Settings
                Section(header: isMatch(searchText: searchText, text: "Language Settings") ? Text("Language Settings") : nil) {
                    if isMatch(searchText: searchText, text: "Language " + viewModel.selectedLanguage) {
                        PickerRow(icon: "globe", title: "Language", selection: $viewModel.selectedLanguage, options: viewModel.languages, color: .blue)
                    }
                }

                // Account Management
                Section(header: isMatch(searchText: searchText, text: "Account Management") ? Text("Account Management") : nil) {
                    if isMatch(searchText: searchText, text: "Account Settings") {
                        NavigationRow(icon: "gearshape.fill", title: "Account Settings", destination: AccountSettingsView(), color: .gray)
                    }
                    if isMatch(searchText: searchText, text: "Danger Zone") {
                        NavigationRow(icon: "exclamationmark.triangle.fill", title: "Danger Zone", destination: DangerZoneView().environmentObject(ChatStore.shared), color: .red)
                    }
                    if isMatch(searchText: searchText, text: "Personal Affirmations") {
                        NavigationRow(icon: "person.bubble.fill", title: "Personal Affirmations", destination: AffirmationsSettingsView(viewModel: SettingsViewModel()), color: .teal)
                    }
                }

                // About & Support
                Section(header: isMatch(searchText: searchText, text: "About & Support") ? Text("About & Support") : nil) {
                    if isMatch(searchText: searchText, text: "About Us") {
                        NavigationRow(icon: "info.circle.fill", title: "About Us", destination: AboutUsView(), color: .blue)
                    }
                    if isMatch(searchText: searchText, text: "App Info") {
                        NavigationRow(icon: "info.bubble.fill", title: "App Info", destination: AppInfoView(), color: .purple)
                    }
                    if isMatch(searchText: searchText, text: "Support & Feedback") {
                        NavigationRow(icon: "questionmark.circle.fill", title: "Support & Feedback", destination: SupportView(), color: .green)
                    }
                }

                // Log Out
                Section(header: isMatch(searchText: searchText, text: "Log Out") ? Text("") : nil) {
                    if isMatch(searchText: searchText, text: "Log Out") {
                        Button(action: {
                            authService.googleSignOut()
                        }) {
                            HStack {
                                Spacer()
                                Text("Log Out")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(viewModel.isDarkMode ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(viewModel.isDarkMode ? .white : .black)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUser()
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
    }

    private func isMatch(searchText: String, text: String) -> Bool {
        searchText.isEmpty || text.lowercased().contains(searchText.lowercased())
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel(authService: AuthenticationService()))
}
