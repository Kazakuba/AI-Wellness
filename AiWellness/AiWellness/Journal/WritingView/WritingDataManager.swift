//
//  WritingDataManager.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//

import Foundation

class WritingDataManager {
    static let shared = WritingDataManager()

    private let defaults = UserDefaults.standard
    private let storageKey = "WritingEntries"

    private init() {}

    func saveText(_ text: String, for date: Date) {
        var entries = loadAllEntries()
        entries[date] = text
        saveAllEntries(entries)
    }

    func getText(for date: Date) -> String {
        let entries = loadAllEntries()
        return entries[date] ?? ""
    }

    func hasContent(for date: Date) -> Bool {
        let entries = loadAllEntries()
        return entries[date]?.isEmpty == false
    }

    private func saveAllEntries(_ entries: [Date: String]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(entries) {
            defaults.set(encoded, forKey: storageKey)
        }
    }

    private func loadAllEntries() -> [Date: String] {
        guard let data = defaults.data(forKey: storageKey) else { return [:] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Date: String].self, from: data)) ?? [:]
    }
}
