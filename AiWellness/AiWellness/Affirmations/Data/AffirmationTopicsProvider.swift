// Sample topics for the UI
import Foundation

struct AffirmationTopicsProvider {
    static var topics: [AffirmationTopic] {
        let month = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
        let year = Calendar.current.component(.year, from: Date())
        return [
            AffirmationTopic(id: "eat_healthy", title: "Eat healthy", iconName: "applelogo"),
            AffirmationTopic(id: "month_affirmations", title: "\(month) Affirmations", iconName: "calendar"),
            AffirmationTopic(id: "stress_anxiety", title: "Control stress", iconName: "sun.max"),
            AffirmationTopic(id: "visualize_year", title: "Visualize \(year)", iconName: "binoculars"),
            AffirmationTopic(id: "self_talk", title: "Improve self-talk", iconName: "pencil"),
            AffirmationTopic(id: "positive_routines", title: "Build habbits", iconName: "heart.text.square"),
            AffirmationTopic(id: "general", title: "General", iconName: "globe"),
            AffirmationTopic(id: "custom", title: "Custom", iconName: "heart")
        ]
    }
}
