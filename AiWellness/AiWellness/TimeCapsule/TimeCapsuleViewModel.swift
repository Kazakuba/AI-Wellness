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
    var savedNotes: [TimeCapsuleNote] = [] // Stored fetched notes
    
    init() {}
    
    let timeframes = ["1 Month", "3 Months", "6 Months", "1 Year"]
    private let persistanceService = PersistenceService.shared
    private let notificationService = NotificationService.shared
    
    func saveNote() -> Bool {
        //Checking if the note content is empty
        guard !noteContent.isEmpty else {
            errorMessage = "Please enter a note."
            return false
        }
        //Create the note with a unique ID
        let note = TimeCapsuleNote(
            id: UUID(),
            content: noteContent,
            unlockDate: calculateUnlockDate()
        )
        
        //Save the note using PersistenceService
        do {
            try persistanceService.saveNote(note: note)
            showConfirmation = true
            fetchNote()
            return true
        } catch {
            errorMessage = "Failed to save the note: \(error.localizedDescription)"
            return false
        }
    }
    
    // Fetch saved notes
    func fetchNote() {
        do {
            savedNotes = try persistanceService.fetchNote()
        } catch {
            errorMessage = "Failed to fetch notes: \(error.localizedDescription)"
            savedNotes = []
        }
    }
    
    func saveNoteAndScheduleNotification(for note: TimeCapsuleNote) {
        NotificationService.shared.scheduleNotification(for: note) { result in
            switch result {
            case .success:
                print("Notifications scheduled successfully!")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
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
    
    func debugResetUserDefaults() {
        persistanceService.debugResetUserDefaults()
    }

}
