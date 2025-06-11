import Foundation
import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let systemImage: String
    let description: String
    var isUnlocked: Bool
    var progress: Int
    var goal: Int
}

// MARK: - Badge Model
struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let systemImage: String
    let description: String
    var level: Int // 0 = locked, 1 = bronze, 2 = silver, 3 = gold
    var progress: Int
    var goal: Int
}

// MARK: - Gamification Manager
class GamificationManager: ObservableObject {
    static let shared = GamificationManager()
    @Published var achievements: [Achievement] = []
    @Published var badges: [Badge] = []
    @Published var xp: Int = 0
    @Published var level: Int = 1
    private let achievementsKey = "gamification_achievements"
    private let badgesKey = "gamification_badges"
    private let xpKey = "gamification_xp"
    private let levelKey = "gamification_level"
    private let userKey = "gamification_user_uid"
    
    // XP values for each achievement/badge (can be customized)
    private let achievementXP: [String: Int] = [
        "first_affirmation": 20,
        "shake_it_up": 15,
        "streak_starter": 25,
        "affirmation_streak": 30,
        "collector": 20,
        "sharing_is_caring": 15,
        "explorer": 10,
        "journal_hero": 20,
        "first_share": 10
    ]
    private let badgeXP: [String: Int] = [
        "level_up": 30,
        "consistency": 20,
        "streak_slayer": 25,
        "collector": 20,
        "shaker": 15,
        "explorer": 10,
        "social_sharer": 15
    ]
    
    // XP needed per level (simple formula: 100 * level)
    private func xpForNextLevel() -> Int { 100 * level }
    
    // MARK: - Initialization
    private init() {
        load()
    }
    
    // MARK: - Achievement Definitions
    private let achievementTemplates: [Achievement] = [
        Achievement(id: "first_affirmation", title: "First Affirmation", systemImage: "sparkles", description: "Unlock one affirmation", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "shake_it_up", title: "Shake it Up!", systemImage: "waveform.path.ecg", description: "Shake gesture 3×", isUnlocked: false, progress: 0, goal: 3),
        Achievement(id: "streak_starter", title: "Streak Starter", systemImage: "flame", description: "3-day streak", isUnlocked: false, progress: 0, goal: 3),
        Achievement(id: "affirmation_streak", title: "Affirmation Streak", systemImage: "calendar", description: "7-day streak", isUnlocked: false, progress: 0, goal: 7),
        Achievement(id: "collector", title: "Collector", systemImage: "tray.full", description: "Save 10 affirmations", isUnlocked: false, progress: 0, goal: 10),
        Achievement(id: "sharing_is_caring", title: "Sharing is Caring", systemImage: "square.and.arrow.up", description: "Share 5×", isUnlocked: false, progress: 0, goal: 5),
        Achievement(id: "explorer", title: "Explorer", systemImage: "globe", description: "View 5 topics", isUnlocked: false, progress: 0, goal: 5),
        Achievement(id: "journal_hero", title: "Journal Hero", systemImage: "book", description: "Complete 5 journal prompts", isUnlocked: false, progress: 0, goal: 5),
        Achievement(id: "first_share", title: "First Share", systemImage: "arrowshape.turn.up.right", description: "Share one affirmation", isUnlocked: false, progress: 0, goal: 1)
    ]
    
    // MARK: - Badge Definitions
    private let badgeTemplates: [Badge] = [
        Badge(id: "level_up", title: "Level Up!", systemImage: "star", description: "New level reached", level: 0, progress: 0, goal: 1),
        Badge(id: "consistency", title: "Consistency", systemImage: "clock", description: "Streaks (3, 7, 30 days)", level: 0, progress: 0, goal: 3),
        Badge(id: "streak_slayer", title: "Streak Slayer", systemImage: "flame", description: "Streaks", level: 0, progress: 0, goal: 3),
        Badge(id: "collector", title: "Collector", systemImage: "tray.full", description: "10+ saves", level: 0, progress: 0, goal: 10),
        Badge(id: "shaker", title: "Shaker", systemImage: "waveform.path.ecg", description: "Multiple shake actions", level: 0, progress: 0, goal: 3),
        Badge(id: "explorer", title: "Explorer", systemImage: "globe", description: "Variety of topics explored", level: 0, progress: 0, goal: 5),
        Badge(id: "social_sharer", title: "Social Sharer", systemImage: "person.2.wave.2", description: "Share actions", level: 0, progress: 0, goal: 5)
    ]
    
    // MARK: - Public API
    func incrementAchievement(_ id: String, by amount: Int = 1) {
        if let idx = achievements.firstIndex(where: { $0.id == id }) {
            var ach = achievements[idx]
            if !ach.isUnlocked {
                ach.progress += amount
                if ach.progress >= ach.goal {
                    ach.isUnlocked = true
                    addXP(achievementXP[id] ?? 10)
                }
                achievements[idx] = ach
                save()
            }
        }
    }
    
    func incrementBadge(_ id: String, by amount: Int = 1) {
        if let idx = badges.firstIndex(where: { $0.id == id }) {
            var badge = badges[idx]
            badge.progress += amount
            if badge.progress >= badge.goal {
                badge.level = min(3, badge.level + 1)
                badge.progress = 0
                addXP(badgeXP[id] ?? 10)
            }
            badges[idx] = badge
            save()
        }
    }
    
    // MARK: - XP/Level Logic
    private func addXP(_ amount: Int) {
        let oldLevel = level
        xp += amount
        while xp >= xpForNextLevel() {
            xp -= xpForNextLevel()
            level += 1
        }
        // --- Level Up! badge logic ---
        if level > oldLevel {
            if let idx = badges.firstIndex(where: { $0.id == "level_up" }) {
                // Award badge at level 2, 5, 10 (bronze, silver, gold)
                let newLevel = level
                var badge = badges[idx]
                if (badge.level < 1 && newLevel >= 2) || (badge.level < 2 && newLevel >= 5) || (badge.level < 3 && newLevel >= 10) {
                    badge.level = min(3, [0, 2, 5, 10].filter { newLevel >= $0 }.count - 1)
                    badge.progress = 0
                } else {
                    badge.progress = newLevel
                }
                badges[idx] = badge
            }
        }
        save()
    }
    
    // MARK: - User UID Storage
    /// Call this after login, before showing any gamification UI.
    /// This will update the user, reload all gamification data, and notify the UI.
    func setUser(uid: String) {
        UserDefaults.standard.set(uid, forKey: userKey)
        load() // Reload data for the new user
        DispatchQueue.main.async {
            self.objectWillChange.send() // Force UI update if needed
        }
    }
    func getUserUID() -> String? {
        UserDefaults.standard.string(forKey: userKey)
    }
    
    // MARK: - Reset All
    func resetAll() {
        achievements = achievementTemplates
        badges = badgeTemplates
        xp = 0
        level = 1
        save()
    }
    
    // MARK: - Persistence (override)
    func save() {
        let uid = getUserUID() ?? "default"
        UserDefaults.standard.set(uid, forKey: userKey)
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "\(achievementsKey)_\(uid)")
        }
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: "\(badgesKey)_\(uid)")
        }
        UserDefaults.standard.set(xp, forKey: "\(xpKey)_\(uid)")
        UserDefaults.standard.set(level, forKey: "\(levelKey)_\(uid)")
    }
    private func load() {
        let uid = getUserUID() ?? "default"
        if let data = UserDefaults.standard.data(forKey: "\(achievementsKey)_\(uid)"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = achievementTemplates
        }
        if let data = UserDefaults.standard.data(forKey: "\(badgesKey)_\(uid)"),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            badges = decoded
        } else {
            badges = badgeTemplates
        }
        xp = UserDefaults.standard.integer(forKey: "\(xpKey)_\(uid)")
        level = UserDefaults.standard.integer(forKey: "\(levelKey)_\(uid)")
        if level < 1 { level = 1 }
    }
}
