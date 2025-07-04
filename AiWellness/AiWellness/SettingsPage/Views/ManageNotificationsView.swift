import SwiftUI
import UserNotifications

struct ManageNotificationsView: View {
    @AppStorage("dailyAffirmationEnabled") private var dailyAffirmation = true
    @AppStorage("streaksEnabled") private var streaks = true
    @AppStorage("journalingEnabled") private var journaling = false
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        List {
            Section(header: Text("Notification Preferences").foregroundColor(isDarkMode ? .white : .black)) {
                Toggle(isOn: $dailyAffirmation) {
                    Text("Receive your daily affirmation")
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .tint(.green)
                .onChange(of: dailyAffirmation) { _, newValue in
                    scheduleNotifications(for: "dailyAffirmation", isEnabled: newValue)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Toggle(isOn: $streaks) {
                    Text("Stay on track with your streaks")
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .tint(.green)
                .onChange(of: streaks) { _, newValue in
                    scheduleNotifications(for: "streaks", isEnabled: newValue)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Toggle(isOn: $journaling) {
                    Text("Helpful nudges for journaling or reflection")
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .tint(.green)
                .onChange(of: journaling) { _, newValue in
                    scheduleNotifications(for: "journaling", isEnabled: newValue)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(isDarkMode ? Color.black : Color.white)
        .navigationTitle("Manage Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .tint(isDarkMode ? .white : .black)
    }

    private func scheduleNotifications(for type: String, isEnabled: Bool) {
        let center = UNUserNotificationCenter.current()
        if !isEnabled {
            let identifier: String
            switch type {
            case "dailyAffirmation": identifier = "dailyAffirmationReminder"
            case "streaks": identifier = "streakReminder"
            case "journaling": identifier = "journalingReminder"
            default: return
            }
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            return
        }
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.schedule(type: type)
                case .notDetermined:
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            self.schedule(type: type)
                        } else {
                            self.toggleBinding(for: type, to: false)
                        }
                    }
                case .denied:
                    NotificationService.shared.promptToEnableNotifications()
                    self.toggleBinding(for: type, to: false)
                @unknown default:
                    self.toggleBinding(for: type, to: false)
                }
            }
        }
    }

    private func schedule(type: String) {
        switch type {
        case "dailyAffirmation":
            NotificationService.shared.scheduleDailyAffirmationReminder()
        case "streaks":
            NotificationService.shared.scheduleStreakReminder()
        case "journaling":
            NotificationService.shared.scheduleJournalingReminder()
        default:
            break
        }
    }

    private func toggleBinding(for type: String, to value: Bool) {
        switch type {
        case "dailyAffirmation":
            dailyAffirmation = value
        case "streaks":
            streaks = value
        case "journaling":
            journaling = value
        default:
            break
        }
    }
}

struct ManageNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManageNotificationsView()
        }
    }
} 
