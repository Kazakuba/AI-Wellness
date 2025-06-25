import Foundation
import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    var title: String
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
    var milestones: [Int]? // Optional: milestone thresholds for each level
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
        "journal_initiate": 20,
        "ai_chat_starter": 25,
        "first_breath": 20
    ]
    private let badgeXP: [String: Int] = [
        "level_up": 30,
        "consistency": 20,
        "collector": 20,
        "shaker": 15,
        "explorer": 10,
        "social_sharer": 15,
        "journal_master": 20,
        "breathwork_pro": 20,
        "ai_conversationalist": 25
    ]
    
    // XP needed per level (simple formula: 100 * level)
    private func xpForNextLevel() -> Int { 50 * level }

    // MARK: - Initialization
    private init() {
        load()
    }
    
    // MARK: - Achievement Definitions (Final List)
    private let achievementTemplates: [Achievement] = [
        Achievement(id: "first_affirmation", title: "First Affirmation", systemImage: "sparkles", description: "Saved your first affirmation", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "shake_it_up", title: "Shake it Up!", systemImage: "waveform.path.ecg", description: "Tried the shake feature", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "journal_initiate", title: "Journal Initiate", systemImage: "book", description: "Wrote your first journal entry", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "ai_chat_starter", title: "AI Chat Starter", systemImage: "message.circle", description: "First time chatting with the AI", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "first_breath", title: "First Breath", systemImage: "lungs", description: "Completed your first breathing session", isUnlocked: false, progress: 0, goal: 1),
        Achievement(id: "hidden_time_capsule", title: "???", systemImage: "clock.arrow.circlepath", description: "When the bass drops and the lights all blink, I'm what you do without a think.", isUnlocked: false, progress: 0, goal: 1)
    ]
    
    // MARK: - Badge Definitions (Complete Badge System)
    private let badgeTemplates: [Badge] = [
        Badge(id: "consistency", title: "Consistency", systemImage: "clock", description: "Daily streaks", level: 0, progress: 0, goal: 3, milestones: [3, 7, 30]),
        Badge(id: "collector", title: "Collector", systemImage: "tray.full", description: "Affirmations saved", level: 0, progress: 0, goal: 10, milestones: [10, 25, 50]),
        Badge(id: "shaker", title: "Shaker", systemImage: "waveform.path.ecg", description: "Device shakes", level: 0, progress: 0, goal: 3, milestones: [3, 10, 25]),
        Badge(id: "explorer", title: "Explorer", systemImage: "globe", description: "Topics viewed", level: 0, progress: 0, goal: 5, milestones: [5, 10, 20]),
        Badge(id: "social_sharer", title: "Social Sharer", systemImage: "person.2.wave.2", description: "Affirmations shared", level: 0, progress: 0, goal: 5, milestones: [5, 15, 30]),
        Badge(id: "journal_master", title: "Journal Master", systemImage: "book.closed", description: "Journal entries completed", level: 0, progress: 0, goal: 5, milestones: [5, 15, 30]),
        Badge(id: "breathwork_pro", title: "Breathwork Pro", systemImage: "lungs.fill", description: "Breathing exercises completed", level: 0, progress: 0, goal: 3, milestones: [3, 10, 25]),
        Badge(id: "ai_conversationalist", title: "AI Conversationalist", systemImage: "message", description: "AI therapy sessions", level: 0, progress: 0, goal: 3, milestones: [3, 10, 20]),
        Badge(id: "level_up", title: "Level Up!", systemImage: "star.fill", description: "App level reached", level: 0, progress: 0, goal: 1, milestones: [2, 5, 10])
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
                    // Special: update title for hidden achievement
                    if id == "hidden_time_capsule" {
                        ach.title = "Time Travel"
                    }
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
            let milestones = badge.milestones ?? [badge.goal]
            while badge.level < 3 {
                let nextMilestoneIndex = badge.level
                if nextMilestoneIndex < milestones.count, badge.progress >= milestones[nextMilestoneIndex] {
                    badge.progress -= milestones[nextMilestoneIndex]
                    badge.level += 1
                    addXP(badgeXP[id] ?? 10)
                } else {
                    break
                }
            }
            // Cap level at 3 (gold)
            if badge.level > 3 { badge.level = 3 }
            badges[idx] = badge
            save()
        }
    }
    
    // Special method for consistency badge that tracks streak value
    func updateConsistencyBadge(streak: Int) {
        if let idx = badges.firstIndex(where: { $0.id == "consistency" }) {
            var badge = badges[idx]

            // Set progress to current streak
            badge.progress = streak
            
            // Check if we should level up based on milestones
            let milestones = badge.milestones ?? [3, 7, 30]

            // Determine what level this streak should be
            var targetLevel = 0
            for (i, milestone) in milestones.enumerated() {
                if streak >= milestone {
                    targetLevel = i + 1
                }
            }

            // Only level up if we're going to a higher level
            if targetLevel > badge.level {
                badge.level = targetLevel
                addXP(badgeXP["consistency"] ?? 10)
            }
            
            badges[idx] = badge
            save()
        }
    }
    
    // Public method to get badge XP
    func getBadgeXP(for id: String) -> Int {
        return badgeXP[id] ?? 10
    }
    
    // MARK: - XP/Level Logic
    func addXP(_ amount: Int) {
        let oldLevel = level
        xp += amount
        while xp >= xpForNextLevel() {
            xp -= xpForNextLevel()
            level += 1
            if level > oldLevel {
                ConfettiManager.shared.celebrate()
            }
        }
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
    // Call this after login, before showing any gamification UI.
    func setUser(uid: String) {
        UserDefaults.standard.set(uid, forKey: userKey)
        load()
        DispatchQueue.main.async {
            self.objectWillChange.send()
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
    
    // MARK: - Reset Achievement Flags (for testing)
    func resetAchievementFlags() {
        let uid = getUserUID() ?? "default"
        let defaults = UserDefaults.standard
        
        // Reset all achievement flags
        defaults.removeObject(forKey: "shake_it_up_\(uid)")
        defaults.removeObject(forKey: "journal_initiate_\(uid)")
        defaults.removeObject(forKey: "ai_chat_starter_\(uid)")
        defaults.removeObject(forKey: "first_breath_\(uid)")
        
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
