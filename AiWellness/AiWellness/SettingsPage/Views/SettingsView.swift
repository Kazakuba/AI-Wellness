import SwiftUI
import ConfettiSwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var authService: AuthenticationService
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @StateObject private var confettiManager = ConfettiManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CustomSearchBar(
                        text: $searchText,
                        isDarkMode: isDarkMode
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listSectionSpacing(50)
                }

                if let user = viewModel.user, isMatch(searchText: searchText, text: user.name + " " + user.email) {
                    accountRow(user: user)
                } else if searchText.isEmpty {
                    accountRow(user: viewModel.user)
                }

                Section(header: Text("Preferences").foregroundColor(dynamicTextColor)) {
                    ToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $viewModel.isDarkMode, color: .indigo)
                    ToggleRow(icon: "bell.fill", title: "Enable Notifications", isOn: $viewModel.notificationsEnabled, color: .orange)
                    if viewModel.notificationsEnabled {
                        NavigationLink("Manage Specific Notifications") {
                            ManageNotificationsView()
                        }
                        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                        .foregroundColor(dynamicTextColor)
                    }
                    if isMatch(searchText: searchText, text: "Danger Zone") {
                        NavigationRow(icon: "exclamationmark.triangle.fill", title: "Danger Zone", destination: DangerZoneView().environmentObject(ChatStore.shared), color: .red)
                    }
                }

                Section(header: isMatch(searchText: searchText, text: "About & Support") ? Text("About & Support").foregroundColor(dynamicTextColor) : nil) {
                    if isMatch(searchText: searchText, text: "GitHub") {
                        Button(action: {
                            if let url = URL(string: "https://github.com/kazakuba/ai-wellness") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left.slash.chevron.right")
                                    .foregroundColor(.yellow)
                                Text("GitHub")
                                    .foregroundColor(dynamicTextColor)
                            }
                        }
                        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                    }
                    if isMatch(searchText: searchText, text: "App Info") {
                        NavigationRow(icon: "info.bubble.fill", title: "App Info", destination: AppInfoView(), color: .purple)
                    }
                    if isMatch(searchText: searchText, text: "Support & Feedback") {
                        NavigationRow(icon: "questionmark.circle.fill", title: "Support & Feedback", destination: SupportView(), color: .green)
                    }
                }

                Section {
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
                        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(dynamicBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(dynamicTextColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(dynamicTextColor)
                    }
                }
            }
            .toolbarBackground(viewModel.isDarkMode ? Color.black : Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
            .tint(isDarkMode ? .white : .black)

            .onAppear {
                viewModel.fetchUser()
            }

        }
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, confettis: confettiManager.confettis, colors: [.yellow, .green, .blue, .orange])
    }

    private func accountRow(user: User?) -> some View {
        HStack {
            AsyncImage(url: URL(string: user?.profileImageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(dynamicTextColor)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(user?.name ?? "Not logged in")
                    .font(.headline)
                    .foregroundColor(dynamicTextColor)
                Text(user?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(dynamicTextColor)
            }
        }
        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)

    }

    private func isMatch(searchText: String, text: String) -> Bool {
        searchText.isEmpty || text.lowercased().contains(searchText.lowercased())
    }

    // MARK: - Dynamic Colors

    private var dynamicBackgroundColor: Color {
        viewModel.isDarkMode ? .black : .white
    }

    private var dynamicTextColor: Color {
        viewModel.isDarkMode ? .white : .black
    }

    private var dynamicRowBackground: Color {
        viewModel.isDarkMode ? Color.customSystemGray6 : Color(.systemGroupedBackground)
    }

    struct CustomSearchBar: View {
        @Binding var text: String
        var isDarkMode: Bool

        var body: some View {
            let placeholderColor = isDarkMode ? Color.white : Color.black
            let backgroundColor = isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(placeholderColor)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Search")
                            .foregroundColor(placeholderColor)
                    }
                    TextField("", text: $text)
                        .foregroundColor(placeholderColor)
                }

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(isDarkMode ? .white.opacity(0.4) : .gray)
                    }
                }
            }
            .padding(8)
            .background(backgroundColor)
            .cornerRadius(10)
            .padding(.horizontal, -4)
        }
    }

}

extension Color {
    static let customSystemGray6 = Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255)
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel(authService: AuthenticationService()))
}
