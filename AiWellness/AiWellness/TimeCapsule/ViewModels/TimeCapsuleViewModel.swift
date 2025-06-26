//
//  TimeCapsuleViewModel.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import SwiftUI
import UserNotifications

//Logic for TimeCapsuleView
//@Observable
class TimeCapsuleViewModel: ObservableObject {
    @Published var noteContent: String = ""
    @Published var selectedTimeframe: String = "1 Month"
    @Published var errorMessage: String?
    @Published var showNotificationPrompt: Bool = false
    @Published var savedNotes: [TimeCapsuleNote] = [] // Stored fetched notes
    @Published var showSavedNotes = false
    @Published var noteToPresent: TimeCapsuleNote? = nil
    @Published var showUnlockedNote = false
    @Published var archivedNotes: [TimeCapsuleNote] = []
    @Published var showArchivedNotes: Bool = false

    private let persistanceService = PersistenceService.shared
    private let notificationService = NotificationService.shared
    
    let timeframes = ["1 Month", "3 Months", "6 Months", "1 Year"]
    
    init() {}
    
    //Saving note
    func saveNote() -> Bool {
        //Checking if the note content is empty
        guard !noteContent.isEmpty else {
            errorMessage = "Please enter a note."
            HapticManager.trigger(.error)
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
            noteContent = ""
            fetchNote()
            HapticManager.trigger(.light)
            notificationService.sendLockConfirmationNotification(for: note)
            return true
        } catch {
            errorMessage = "Failed to save the note: \(error.localizedDescription)"
            HapticManager.trigger(.error)
            return false
        }
    }
    
    func confirmAndSaveNote(dismissKeyboard: (() -> Void)? = nil) {
        if saveNote() {
            checkAndMaybeRequestPermissionAndSchedule()
            DispatchQueue.main.async {
                self.objectWillChange.send()
                dismissKeyboard?()
            }
        }
    }
    
    func checkAndMaybeRequestPermissionAndSchedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.scheduleLatestNoteNotification()
                    self.notificationService.sendPermissionConfirmationNotification()
                    self.showNotificationPrompt = false
                case .notDetermined:
                    self.requestNotificationPermissionAndSchedule() // Will ask for permission
                case .denied, .ephemeral:
                    self.showNotificationPrompt = true // Suggest enabling in settings
                @unknown default:
                    self.showNotificationPrompt = true
                }
            }
        }
    }

    // Fetching saved notes
    func fetchNote() {
        do {
            savedNotes = try persistanceService.fetchNote()
            // archiveExpiredNotes() // Do not auto-archive, keep all notes in main list
        } catch {
            errorMessage = "Failed to fetch notes: \(error.localizedDescription)"
            savedNotes = []
        }
    }
    
    //Fetching archived notes
    func fetchArchivedNotes() {
        do {
            archivedNotes = try persistanceService.fetchArchivedNotes()
        } catch {
            errorMessage = "Failed to load archived notes: \(error.localizedDescription)"
        }
    }

    //For deleting just one note
    func deleteNote(_ note: TimeCapsuleNote) {
        do {
            try persistanceService.deleteNote(withId: note.id)
            fetchNote()
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
    }
    
    //Deleting one archived note
    func deleteArchivedNote(_ note: TimeCapsuleNote) {
        do {
            var archived = try persistanceService.fetchArchivedNotes()
            archived.removeAll { $0.id == note.id }
            try persistanceService.overwriteArchivedNotes(archived)
            archivedNotes = archived
            HapticManager.trigger(.warning)
        } catch {
            errorMessage = "Failed to delete archived note: \(error.localizedDescription)"
        }
    }
    
    //Deleting all archived notes
    func deleteAllArchivedNotes() {
        do {
            try persistanceService.overwriteArchivedNotes([])
            archivedNotes = []
            HapticManager.trigger(.success)
        } catch {
            errorMessage = "Failed to delete all archived notes: \(error.localizedDescription)"
        }
    }
    
    //To move expired notes to archive
    func archiveExpiredNotes() {
        let now = Date()
        let expiredNotes = savedNotes.filter { $0.unlockDate < now }
        
        guard !expiredNotes.isEmpty else { return }
        
        do {
            try persistanceService.archiveExpiredNotes(expiredNotes)
            fetchNote()
        } catch {
            errorMessage = "Failed to archive notes: \(error.localizedDescription)"
            HapticManager.trigger(.error)
        }
    }
    
    //Ask permission for sending notification
    func requestNotificationPermissionAndSchedule() {
        notificationService.requestPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleLatestNoteNotification()
                    self.notificationService.sendPermissionConfirmationNotification()
                    self.showNotificationPrompt = false
                } else {
                    self.notificationService.promptToEnableNotifications()
                }
            }
        }
    }
    
    //Checking current nitification status - handles whether to schedule a notification or prompt the user after saving a note
    func checkNotificationAuthorizationAndPromptIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    // Notifications are allowed → don't show the prompt
                    self.showNotificationPrompt = false
                case .notDetermined, .denied, .ephemeral:
                    // Notifications are not allowed → show the prompt
                    self.showNotificationPrompt = true
                @unknown default:
                    self.showNotificationPrompt = true
                }
            }
        }
    }
    
    func updatePromptVisibilityBasedOnNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.showNotificationPrompt = false
                case .denied, .notDetermined, .ephemeral:
                    self.showNotificationPrompt = true
                @unknown default:
                    self.showNotificationPrompt = false
                }
            }
        }
    }
    
    //Also checking notification status but for only one reason - dismissing the notification prompt if the user has granted permission
    func checkNotificationAuthorizationAndDismissIfGranted() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                    self.showNotificationPrompt = false
                }
            }
        }
    }
    
    //Clearing all saved notes both active and archived, and then reloads the list
    func resetNotesStorage() {
        persistanceService.resetNotesStorage()
        fetchNote()
    }
    
    //Calculating how far in the future to lock the time capsule note
    private func calculateUnlockDate() -> Date {
        let timeIntervals: [String: TimeInterval] = [
            "1 Month": 60 * 60 * 24 * 30,
            "3 Months": 60 * 60 * 24 * 30 * 3,
            "6 Months": 60 * 60 * 24 * 30 * 6,
            "1 Year": 60 * 60 * 24 * 365
        ]
        return Date().addingTimeInterval(timeIntervals[selectedTimeframe] ?? 60 * 60 * 24 * 30)
    }
    
    private func scheduleLatestNoteNotification() {
        guard let note = savedNotes.last else { return }
        
        notificationService.scheduleNotification(for: note, at: note.unlockDate) { result in
            switch result {
            case .success:
                print("Notification scheduled successfully.")
            case .failure(let error):
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
