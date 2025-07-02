//
//  DeliveryTimeViewModel.swift
//  AiWellness
//
//  Created by Kazakuba on 24. 4. 25.
//

import Foundation
import SwiftUI

class DeliveryTimeViewModel: ObservableObject {
    @ObservedObject var notificationService = NotificationService()
    @Published var selectedTime = Date()
    
    func didSet() {
        saveSelectedTime()
    }
    
    private let timeKey = "DailyNoticifationTime"
    
    init () {
        //Load saved time or use default 8:00 AM
        if let savedTime = UserDefaults.standard.object(forKey: timeKey) as? Date {
            self.selectedTime = savedTime
        } else {
            var defaultDateComponents = DateComponents()
            defaultDateComponents.hour = 8
            defaultDateComponents.minute = 0
            self.selectedTime = Calendar.current.date(from: defaultDateComponents) ?? Date()
        }
    }
    
    func saveSelectedTime() {
        UserDefaults.standard.set(selectedTime, forKey: timeKey)
    }
    
    func scheduleNotificationTime() {
        guard let nextTrigger = Date.nextOccurence(of: selectedTime) else {
            print("Could not calculate next trigger time")
            return
        }
        
        let note = TimeCapsuleNote(
            id: UUID(),
            content: "Here's your daily affirmation!",
            unlockDate: nextTrigger)
        
        NotificationService.shared.scheduleNotification(for: note, at: note.unlockDate) { result in
            switch result {
            case .success():
                print("Notification schedule at \(nextTrigger)")
            case .failure(let error):
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatted = DateFormatter()
        formatted.timeStyle = .short
        return formatted.string(from: date)
    }
}

// Safely compute the next valid time
extension Date {
    static func nextOccurence(of time: Date) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let today = calendar.date(bySettingHour: components.hour ?? 0,
                                        minute: components.minute ?? 0,
                                        second: 0,
                                        of: now) else {
            return nil
        }
        return today > now ? today : calendar.date(byAdding: .day, value: 1, to: today)!
    }
}
