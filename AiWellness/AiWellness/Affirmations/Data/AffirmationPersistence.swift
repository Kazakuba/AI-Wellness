// Data layer: Local persistence for affirmations
import Foundation

class AffirmationPersistence {
    private func savedKey(for uid: String?) -> String { "saved_affirmations_\(uid ?? "default")" }
    private func todayKey(for uid: String?) -> String { "today_affirmation_\(uid ?? "default")" }
    private func todayDateKey(for uid: String?) -> String { "today_affirmation_date_\(uid ?? "default")" }
    private func todayTopicKey(for uid: String?) -> String { "today_affirmation_topic_map_\(uid ?? "default")" }
    
    func saveAffirmation(_ affirmation: Affirmation, uid: String?) {
        var affirmations = getSavedAffirmations(uid: uid)
        if !affirmations.contains(affirmation) {
            affirmations.append(affirmation)
            saveAffirmations(affirmations, uid: uid)
        }
    }
    
    func getSavedAffirmations(uid: String?) -> [Affirmation] {
        guard let data = UserDefaults.standard.data(forKey: savedKey(for: uid)),
              let affirmations = try? JSONDecoder().decode([Affirmation].self, from: data) else {
            return []
        }
        return affirmations
    }
    
    func isAffirmationSaved(_ affirmation: Affirmation, uid: String?) -> Bool {
        getSavedAffirmations(uid: uid).contains(affirmation)
    }
    
    func saveAffirmations(_ affirmations: [Affirmation], uid: String?) {
        if let data = try? JSONEncoder().encode(affirmations) {
            UserDefaults.standard.set(data, forKey: savedKey(for: uid))
        }
    }
    
    func saveTodayAffirmation(_ affirmation: Affirmation, uid: String?) {
        if let data = try? JSONEncoder().encode(affirmation) {
            UserDefaults.standard.set(data, forKey: todayKey(for: uid))
            UserDefaults.standard.set(Date(), forKey: todayDateKey(for: uid))
        }
        var topicMap = getTodayAffirmationTopicMap(uid: uid)
        if let topic = affirmation.topic {
            topicMap[topic] = (affirmation, Date())
            let encodableMap: [String: [AffirmationOrDate]] = topicMap.mapValues { [AffirmationOrDate(affirmation: $0.0, date: nil), AffirmationOrDate(affirmation: nil, date: $0.1)] }
            if let data = try? JSONEncoder().encode(encodableMap) {
                UserDefaults.standard.set(data, forKey: todayTopicKey(for: uid))
            }
        }
    }

    func getTodayAffirmation(for topic: String?, uid: String?) -> Affirmation? {
        guard let topic = topic else { return getTodayAffirmation(uid: uid) }
        let topicMap = getTodayAffirmationTopicMap(uid: uid)
        if let (affirmation, date) = topicMap[topic], Calendar.current.isDateInToday(date) {
            return affirmation
        }
        return nil
    }

    func getTodayAffirmation(uid: String?) -> Affirmation? {
        guard let date = UserDefaults.standard.object(forKey: todayDateKey(for: uid)) as? Date,
              Calendar.current.isDateInToday(date),
              let data = UserDefaults.standard.data(forKey: todayKey(for: uid)),
              let affirmation = try? JSONDecoder().decode(Affirmation.self, from: data) else {
            return nil
        }
        return affirmation
    }

    private func getTodayAffirmationTopicMap(uid: String?) -> [String: (Affirmation, Date)] {
        guard let data = UserDefaults.standard.data(forKey: todayTopicKey(for: uid)),
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
    
    func deleteAffirmation(_ affirmation: Affirmation, uid: String?) {
        var affirmations = getSavedAffirmations(uid: uid)
        if let index = affirmations.firstIndex(of: affirmation) {
            affirmations.remove(at: index)
            saveAffirmations(affirmations, uid: uid)
        }
    }
    
    func clearAllAffirmations(uid: String?) {
        UserDefaults.standard.removeObject(forKey: savedKey(for: uid))
    }

    private struct AffirmationOrDate: Codable {
        let affirmation: Affirmation?
        let date: Date?
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
