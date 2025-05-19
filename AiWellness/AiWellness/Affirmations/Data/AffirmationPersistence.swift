// Data layer: Local persistence for affirmations (UserDefaults for MVP)
import Foundation

class AffirmationPersistence {
    private let savedKey = "saved_affirmations"
    private let todayKey = "today_affirmation"
    private let todayDateKey = "today_affirmation_date"
    
    // Store daily affirmations per topic and date
    private let todayTopicKey = "today_affirmation_topic_map"

    func saveAffirmation(_ affirmation: Affirmation) {
        var affirmations = getSavedAffirmations()
        if !affirmations.contains(affirmation) {
            affirmations.append(affirmation)
            saveAffirmations(affirmations)
        }
    }
    
    func getSavedAffirmations() -> [Affirmation] {
        guard let data = UserDefaults.standard.data(forKey: savedKey),
              let affirmations = try? JSONDecoder().decode([Affirmation].self, from: data) else {
            return []
        }
        return affirmations
    }
    
    func isAffirmationSaved(_ affirmation: Affirmation) -> Bool {
        getSavedAffirmations().contains(affirmation)
    }
    
    func saveAffirmations(_ affirmations: [Affirmation]) {
        if let data = try? JSONEncoder().encode(affirmations) {
            UserDefaults.standard.set(data, forKey: savedKey)
        }
    }
    
    // Save today's affirmation for a topic
    func saveTodayAffirmation(_ affirmation: Affirmation) {
        // Save for legacy single-topic
        if let data = try? JSONEncoder().encode(affirmation) {
            UserDefaults.standard.set(data, forKey: todayKey)
            UserDefaults.standard.set(Date(), forKey: todayDateKey)
        }
        // Save for per-topic
        var topicMap = getTodayAffirmationTopicMap()
        if let topic = affirmation.topic {
            topicMap[topic] = (affirmation, Date())
            // Encode as [String: [AffirmationOrDate]]
            let encodableMap: [String: [AffirmationOrDate]] = topicMap.mapValues { [AffirmationOrDate(affirmation: $0.0, date: nil), AffirmationOrDate(affirmation: nil, date: $0.1)] }
            if let data = try? JSONEncoder().encode(encodableMap) {
                UserDefaults.standard.set(data, forKey: todayTopicKey)
            }
        }
    }

    // Get today's affirmation for a topic
    func getTodayAffirmation(for topic: String?) -> Affirmation? {
        guard let topic = topic else { return getTodayAffirmation() }
        let topicMap = getTodayAffirmationTopicMap()
        if let (affirmation, date) = topicMap[topic], Calendar.current.isDateInToday(date) {
            return affirmation
        }
        return nil
    }

    // Get today's affirmation (legacy single-topic support)
    func getTodayAffirmation() -> Affirmation? {
        guard let date = UserDefaults.standard.object(forKey: todayDateKey) as? Date,
              Calendar.current.isDateInToday(date),
              let data = UserDefaults.standard.data(forKey: todayKey),
              let affirmation = try? JSONDecoder().decode(Affirmation.self, from: data) else {
            return nil
        }
        return affirmation
    }

    // Helper: get topic map from UserDefaults
    private func getTodayAffirmationTopicMap() -> [String: (Affirmation, Date)] {
        guard let data = UserDefaults.standard.data(forKey: todayTopicKey),
              let raw = try? JSONDecoder().decode([String: [AffirmationOrDate]].self, from: data) else {
            return [:]
        }
        var result: [String: (Affirmation, Date)] = [:]
        for (topic, arr) in raw {
            if arr.count == 2, let affirmation = arr[0].affirmation, let date = arr[1].date {
                result[topic] = (affirmation, date)
            }
        }
        return result
    }

    // Helper struct for decoding
    private struct AffirmationOrDate: Codable {
        let affirmation: Affirmation?
        let date: Date?
        // Explicit initializer for encoding
        init(affirmation: Affirmation?, date: Date?) {
            self.affirmation = affirmation
            self.date = date
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let affirmation = try? container.decode(Affirmation.self) {
                self.affirmation = affirmation
                self.date = nil
            } else if let date = try? container.decode(Date.self) {
                self.affirmation = nil
                self.date = date
            } else {
                self.affirmation = nil
                self.date = nil
            }
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            if let affirmation = affirmation {
                try container.encode(affirmation)
            } else if let date = date {
                try container.encode(date)
            }
        }
    }
}
