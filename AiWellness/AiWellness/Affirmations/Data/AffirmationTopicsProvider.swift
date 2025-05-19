// Sample topics for the UI (can be loaded from API or local JSON)
import Foundation

struct AffirmationTopicsProvider {
    static let topics: [AffirmationTopic] = [
        AffirmationTopic(id: "eat_healthy", title: "Eat healthy", iconName: "applelogo"),
        AffirmationTopic(id: "january_affirmations", title: "January affirmations", iconName: "calendar"),
        AffirmationTopic(id: "stress_anxiety", title: "Control stress and anxiety", iconName: "sun.max"),
        AffirmationTopic(id: "visualize_2025", title: "Visualize 2025", iconName: "binoculars"),
        AffirmationTopic(id: "self_talk", title: "Improve self-talk", iconName: "pencil"),
        AffirmationTopic(id: "new_habits", title: "Establish new habits", iconName: "heart.text.square"),
        AffirmationTopic(id: "general", title: "General", iconName: "globe"),
        AffirmationTopic(id: "favorites", title: "Your favorites", iconName: "heart"),
        AffirmationTopic(id: "custom", title: "My own affirmations", iconName: "pencil.and.outline")
    ]
}
