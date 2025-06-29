import SwiftUI
import UserNotifications

struct ManageNotificationsView: View {
    @AppStorage("dailyAffirmationEnabled") private var dailyAffirmation = true
    @AppStorage("streaksEnabled") private var streaks = true
    @AppStorage("journalingEnabled") private var journaling = false

    var body: some View {
        Form {
            Section(header: Text("Notification Preferences")) {
                Toggle("Receive your daily affirmation", isOn: $dailyAffirmation)
                    .onChange(of: dailyAffirmation) { _, newValue in
                        scheduleNotifications(for: "dailyAffirmation", isEnabled: newValue)
                    }

                Toggle("Stay on track with your streaks", isOn: $streaks)
                    .onChange(of: streaks) { _, newValue in
                        scheduleNotifications(for: "streaks", isEnabled: newValue)
                    }

                Toggle("Helpful nudges for journaling or reflection", isOn: $journaling)
                    .onChange(of: journaling) { _, newValue in
                        scheduleNotifications(for: "journaling", isEnabled: newValue)
                    }
            }
        }
        .navigationTitle("Manage Notifications")
        .navigationBarTitleDisplayMode(.inline)
        
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
