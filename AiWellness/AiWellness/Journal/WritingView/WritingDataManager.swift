//
//  WritingDataManager.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//

import Foundation
import FirebaseAuth

class WritingDataManager {
    static let shared = WritingDataManager()

    private let defaults = UserDefaults.standard
    private let storageKey = "WritingEntries_"

    private init() {}

    // Helper to get current Google UID
    private func currentGoogleUID() -> String? {
        return Auth.auth().currentUser?.uid
    }

    // Save a note for a specific date, scoped to user
    func saveText(_ text: String, for date: Date) {
        guard let uid = currentGoogleUID() else { return }
        var entries = loadAllEntries(for: uid)
        entries[date] = text
        saveAllEntries(entries, for: uid)
    }

    // Get a note for a specific date, scoped to user
    func getText(for date: Date) -> String {
        guard let uid = currentGoogleUID() else { return "" }
        let entries = loadAllEntries(for: uid)
        return entries[date] ?? ""
    }

    // Check if there is content for a specific date, scoped to user
    func hasContent(for date: Date) -> Bool {
        guard let uid = currentGoogleUID() else { return false }
        let entries = loadAllEntries(for: uid)
        return entries[date]?.isEmpty == false
    }

    // Fetch the earliest date with a note, scoped to user
    func earliestNoteDate() -> Date? {
        guard let uid = currentGoogleUID() else { return nil }
        let entries = loadAllEntries(for: uid)
        return entries.keys.min()
    }

    // Save all entries to UserDefaults for a user
    private func saveAllEntries(_ entries: [Date: String], for uid: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(entries) {
            defaults.set(encoded, forKey: storageKey + uid)
        }
    }

    // Load all entries from UserDefaults for a user
    func loadAllEntries(for uid: String) -> [Date: String] {
        guard let data = defaults.data(forKey: storageKey + uid) else { return [:] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Date: String].self, from: data)) ?? [:]
    }

    // Delete all entries for the current user
    func deleteAllEntries() {
        guard let uid = currentGoogleUID() else { return }
        defaults.removeObject(forKey: storageKey + uid)
    }
}
