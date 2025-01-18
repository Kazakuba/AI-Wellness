//
//  TimeCapsuleViewModel.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import SwiftUI

//Logic for TimeCapsuleView
@Observable
class TimeCapsuleViewModel {
     var noteContent: String = ""
     var selectedTimeframe: String = "1 Month"
     var errorMessage: String?
     var showConfirmation: Bool = false
    
    init() {}

    let timeframes = ["1 Month", "3 Months", "6 Months", "1 Year"]
    private let persistanceService = PersistenceService.shared
    private let notificationService = NotificationService.shared
    
    func saveNote() -> Bool {
        guard !noteContent.isEmpty else {
            errorMessage = "Please enter a note."
            return false
        }
        print("Note saved: \(noteContent), Timeframe: \(selectedTimeframe)")
        return true
    }
    
    private func calculateUnlockDate() -> Date {
        let timeIntervals: [String: TimeInterval] = [
            "1 Month": 60 * 60 * 24 * 30,
            "3 Months": 60 * 60 * 24 * 30 * 3,
            "6 Months": 60 * 60 * 24 * 30 * 6,
            "1 Year": 60 * 60 * 24 * 365
            ]
        return Date().addingTimeInterval(timeIntervals[selectedTimeframe] ?? 60 * 60 * 24 * 30)
    }
}
