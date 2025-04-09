//
//  SettingsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 9. 2. 25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                //Account Section
                    if let user = viewModel.user {
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
                    } else {
                        Text("Not logged in")
                            .foregroundColor(.gray)
                    }
              
                // Preferences
                Section(header: Text("Preferences")) {
                    SettingsRow(icon: "paintbrush.fill", title: "Color Scheme", color: .brown)
                    PickerRow(icon: "paintpalette.fill", title: "App Icon", selection: $viewModel.selectedAppIcon, options: viewModel.appIcons, color: .orange)
                    ToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $viewModel.isDarkMode, color: .gray)
                        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)  // Apply the theme
                    PickerRow(icon: "waveform", title: "Voice", selection: $viewModel.selectedAIVoice, options: viewModel.aiVoice, color: .cyan)
                }
               
                //Notifications
                Section(header: Text("Notifications")) {
                    ToggleRow(icon: "bell.fill", title: "Enable Notifications", isOn: $viewModel.notificationsEnabled, color: .pink)
                    
                    if viewModel.notificationsEnabled {
                        NavigationLink("Manage Specific Notifications") {
                            Text("Notification Preferences Coming Soon")
                        }
                    }
                }
                
                //Language Settings
                Section(header: Text("Language Settings")) {
                    PickerRow(icon: "globe", title: "Language", selection: $viewModel.selectedLanguage, options: viewModel.languages, color: .blue)
                }
                
                //Account Management
                Section(header: Text("Account Management")) {
                    NavigationRow(icon: "gearshape.fill", title: "Account Settings", destination: AccountSettingsView(), color: .gray)
                    NavigationRow(icon: "exclamationmark.triangle.fill", title: "Danger Zone", destination: DangerZoneView(), color: .red)
                    NavigationRow(icon: "person.bubble.fill", title: "Personal Affirmations", destination: AffirmationsSettingsView(viewModel: SettingsViewModel()), color: .teal)
                }
                
                //About & Support
                Section(header: Text("About & Support")) {
                    NavigationRow(icon: "info.circle.fill", title: "About Us", destination: AboutUsView(), color: .blue)
                    NavigationRow(icon: "info.bubble.fill", title: "App Info", destination: AppInfoView(), color: .purple)
                    NavigationRow(icon: "questionmark.circle.fill", title: "Support & Feedback", destination: SupportView(), color: .green)
                }
               
                //Log Out
                Section {
                    Button(action : { viewModel.googleSignOut() }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.fetchUser() // Fetch user data when the settings page appears
            }
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .automatic, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}

struct FadingViewModifier: ViewModifier {
    @State private var opacity: Double = 0.0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func fadingTransition() -> some View {
        self.modifier(FadingViewModifier())
    }
}
