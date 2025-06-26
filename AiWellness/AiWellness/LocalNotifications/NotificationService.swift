//
//  NotificationService.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import UserNotifications
import SwiftUI

// Handeling local notifications
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private let affirmationHistoryKey = "affirmationHistory"
    
    // Request permission for notifications
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    // Check notification settings
    func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                // Notifications fully allowed; Provisional notifications allowed; Temporary session-based authorization
            case .authorized, .provisional, .ephemeral:
                completion(true)
                // Notifications explicitly denied; User hasn't been asked for permission yet
            case .denied, .notDetermined:
                completion(false)
            @unknown default: // Catch any future unknown cases
                completion(false)
            }
        }
    }
    
    // Enabling notifications
    func promptToEnableNotifications() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Enable Notifications",
                message: "Notifications are disabled. Please enable them in Settings to use this feature.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
    
    // Scedule a notification for TimeCapsule
    func scheduleNotification(for note: TimeCapsuleNote, at date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        checkNotificationAuthorization { isAuthorized in
            guard isAuthorized else {
                completion(.failure(NSError(domain: "NotificationError", code: 403, userInfo: [
                    NSLocalizedDescriptionKey: "Notifications are disabled. Please enable them in Settings."
                ])))
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Your Time Capsule Note Is Ready!"
            content.body = "Open app to read your note \(note.content.shortened(to: 100))"
            content.sound = UNNotificationSound.defaultCritical
            
            if let encodedNote = try? JSONEncoder().encode(note) {
                content.userInfo = ["note": encodedNote.base64EncodedString()]
                print("Encoded note: \(encodedNote.base64EncodedString())")
            }
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
                repeats: false
            )
            
            let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
            
            //Removing any existing pending notification for this note
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [note.id.uuidString])
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.saveAffirmationToHistory(text: note.content, date: note.unlockDate)
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func sendLockConfirmationNotification(for note: TimeCapsuleNote) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized. Skipping lock confirmation.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Your message to the future is locked"
            content.body = "It will unlock on \(self.formattedDate(note.unlockDate))."
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil // Send immediately
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to send lock confirmation: \(error.localizedDescription)")
                } else {
                    print("Lock confirmation notification sent")
                }
            }
        }
    }
    
    func scheduleCheckInReminder(frequency: String = "daily") {
        let content = UNMutableNotificationContent()
        content.title = "Write for Your Future Self"
        content.body = "Write something today that your future self will appreciate."
        content.sound = .default
        
        var dateComponents = DateComponents()
        if frequency == "daily" {
            dateComponents.hour = 9 // every day at 9 AM
        } else if frequency == "weekly" {
            dateComponents.weekday = 2 // every Monday
            dateComponents.hour = 9
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "checkInReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule check-in reminder: \(error)")
            } else {
                print("Check-in reminder scheduled (\(frequency))")
            }
        }
    }
    
    func scheduleDailyAffirmationReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Affirmation Awaits"
        content.body = "Start your day with a positive thought. Open AiWellness to see your affirmation!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM daily

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyAffirmationReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily affirmation: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled daily affirmation reminder.")
            }
        }
    }

    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Going!"
        content.body = "A small step every day leads to big results. Hop back in to maintain your streak."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 19 // 7 PM daily

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streakReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled streak reminder.")
            }
        }
    }

    func scheduleJournalingReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Reflect"
        content.body = "How was your day? Take a moment to capture your thoughts in your journal."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM daily

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "journalingReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling journaling reminder: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled journaling reminder.")
            }
        }
    }
    
    func sendPermissionConfirmationNotification() {
        let key = "confirmationNotificationSent"
        
        //Prevent sending it more than once
        if UserDefaults.standard.bool(forKey: key) {
            print("Confirmation already sent. Skipping.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "You're All Set!"
        content.body = "You'll be reminded when it's time to read your note."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Send immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send confirmation: \(error)")
            } else {
                print("Confirmation notification sent")
                UserDefaults.standard.set(true, forKey: key) //Mark as sent
            }
        }
    }
    
    func saveAffirmationToHistory(text: String, date: Date) {
        var history: [Affirmation] = []
        
        if let data = UserDefaults.standard.data(forKey: affirmationHistoryKey),
           let decoded = try? JSONDecoder().decode([Affirmation].self, from: data) {
            history = decoded
        }
        
        let newAffirmation = Affirmation(
            id: UUID(),
            text: text,
            date: date,
            topic: nil,          // No topic from TimeCapsuleNote
            isFavorite: false    // Default value
        )
        
        history.append(newAffirmation)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: affirmationHistoryKey)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension String {
    func shortened(to maxLength: Int) -> String {
        return count <= maxLength ? self : String(prefix(maxLength)) + "..."
    }
}

extension Notification.Name {
    static let didReceiveAffirmationNotification = Notification.Name("didReceiveAffirmationNotification")
}
