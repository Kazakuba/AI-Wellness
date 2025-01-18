//
//  NotificationService.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import UserNotifications

// Handeling local notifications
class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge]) { granted, _ in
            completion(granted)
        }
    }
    
    func scheduleNotification(for note: TimeCapsuleNote) {
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
        UNUserNotificationCenter.current().add(request)
    }
}
