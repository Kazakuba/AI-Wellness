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
            content.sound = .default
            
            let triggerDate = note.unlockDate
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
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
}

extension String {
    func shortened(to maxLenght: Int) -> String {
        if self.count <= maxLenght {
            return self
        } else {
            let index = self.index(self.startIndex, offsetBy: maxLenght)
            return String(self[..<index]) + "..."
        }
    }
}

extension Notification.Name {
    static let didReceiveAffirmationNotification = Notification.Name("didReceiveAffirmationNotification")
}
