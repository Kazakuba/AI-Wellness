//
//  NotificationService.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import UserNotifications
import SwiftUI

// Handeling local notifications
class NotificationService {
    static let shared = NotificationService()
    
    // Request permission for notifications
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge]) { granted, _ in
            completion(granted)
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
    
    // Scedule a notification
    func scheduleNotification(for note: TimeCapsuleNote, completion: @escaping (Result<Void, Error>) -> Void) {
        checkNotificationAuthorization { isAuthorized in
            guard isAuthorized else {
                completion(.failure(NSError(domain: "NotificationError", code: 403, userInfo: [
                    NSLocalizedDescriptionKey: "Notifications are disabled. Please enable them in Settings."
                ])))
                return
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "Your Time Capsule Note Is Ready!"
        content.body = "Open app to read your note \(note.content)"
        content.sound = .default
        
        let triggerDate = note.unlockDate
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
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
