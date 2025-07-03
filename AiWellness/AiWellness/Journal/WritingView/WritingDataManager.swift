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

    private func currentGoogleUID() -> String? {
        return Auth.auth().currentUser?.uid
    }

    func saveText(_ text: String, for date: Date) {
        guard let uid = currentGoogleUID() else { return }
        var entries = loadAllEntries(for: uid)
        entries[date] = text
        saveAllEntries(entries, for: uid)
    }

    func getText(for date: Date) -> String {
        guard let uid = currentGoogleUID() else { return "" }
        let entries = loadAllEntries(for: uid)
        return entries[date] ?? ""
    }

    func hasContent(for date: Date) -> Bool {
        guard let uid = currentGoogleUID() else { return false }
        let entries = loadAllEntries(for: uid)
        return entries[date]?.isEmpty == false
    }

    func earliestNoteDate() -> Date? {
        guard let uid = currentGoogleUID() else { return nil }
        let entries = loadAllEntries(for: uid)
        return entries.keys.min()
    }

    private func saveAllEntries(_ entries: [Date: String], for uid: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(entries) {
            defaults.set(encoded, forKey: storageKey + uid)
        }
    }

    func loadAllEntries(for uid: String) -> [Date: String] {
        guard let data = defaults.data(forKey: storageKey + uid) else { return [:] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Date: String].self, from: data)) ?? [:]
    }

    func deleteAllEntries() {
        guard let uid = currentGoogleUID() else { return }
        defaults.removeObject(forKey: storageKey + uid)
    }
}
