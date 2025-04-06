import SwiftUI

// MARK: - Breathing Patterns
struct BreathingPatterns {
    // Breathing patterns by animation type
    static let patterns: [String: (inhale: Double, hold1: Double, exhale: Double, hold2: Double)] = [
        "Square": (inhale: 4, hold1: 4, exhale: 4, hold2: 4), // Box breathing
        "Circle": (inhale: 4, hold1: 0, exhale: 4, hold2: 0), // Equal breathing
        "Triangle": (inhale: 4, hold1: 0, exhale: 6, hold2: 0), // 4-6 breathing
        "Calm": (inhale: 4, hold1: 7, exhale: 8, hold2: 0),  // 4-7-8 breathing
        "Energy": (inhale: 6, hold1: 2, exhale: 4, hold2: 0),  // Energizing breath
        "Focus": (inhale: 5, hold1: 2, exhale: 7, hold2: 0)   // Focus breathing
    ]
    
    static func getPattern(for animationType: String) -> (inhale: Double, hold1: Double, exhale: Double, hold2: Double) {
        return patterns[animationType] ?? (inhale: 4, hold1: 4, exhale: 4, hold2: 4)
    }
}

// MARK: - Theme Categories
struct ThemeCategories {
    static let categories: [String: [String]] = [
        "Stress Relief": ["Square", "Calm"],
        "Sleep": ["Calm", "Circle"],
        "Energy": ["Energy", "Triangle"],
        "Focus": ["Focus", "Square"],
        "Beginner": ["Circle", "Square"]
    ]
    
    static let allThemes = ["Square", "Circle", "Triangle", "Calm", "Energy", "Focus"]
    
    static func getThemesForCategory(_ category: String) -> [String] {
        if category == "All" {
            return allThemes
        }
        return categories[category] ?? allThemes
    }
}

// MARK: - Instructions Text
struct BreathingInstructions {
    static let instructionsByType: [String: String] = [
        "Square": "Box breathing: Inhale for 4 counts, hold for 4, exhale for 4, and hold for 4. This square pattern helps reduce stress and improve concentration.",
        "Circle": "Equal breathing: Breathe in and out for equal counts of 4. This balanced pattern promotes calm and is ideal for daily practice.",
        "Triangle": "Extended exhale: Inhale for 4 counts and exhale for 6. This extended exhale pattern activates your parasympathetic nervous system, reducing anxiety.",
        "Calm": "4-7-8 breathing: Inhale for 4 counts, hold for 7, and exhale for 8. This powerful relaxation technique can help with sleep and anxiety.",
        "Energy": "Energizing breath: Inhale for 6, hold briefly for 2, and exhale for 4. This pattern increases alertness and energy levels.",
        "Focus": "Focus breathing: Inhale for 5, hold for 2, exhale for 7. This technique improves mental clarity and concentration for tasks requiring attention."
    ]
    
    static func getInstructions(for type: String) -> String {
        return instructionsByType[type] ?? ""
    }
    
    static func getPhaseInstruction(for phase: BreathingPhase) -> String {
        switch phase {
        case .inhale:
            return "Breathe in"
        case .hold1:
            return "Hold"
        case .exhale:
            return "Breathe out"
        case .hold2:
            return "Hold"
        }
    }
}

// MARK: - Animation Visual Properties
struct AnimationVisuals {
    static func getIconName(for type: String) -> String {
        switch type {
        case "Square":
            return "square"
        case "Circle":
            return "circle"
        case "Triangle":
            return "triangle"
        case "Calm":
            return "cloud"
        case "Energy":
            return "bolt"
        case "Focus":
            return "brain"
        default:
            return "circle"
        }
    }
    
    static func getColor(for type: String) -> Color {
        switch type {
        case "Square":
            return Color.blue
        case "Circle":
            return Color.purple
        case "Triangle":
            return Color.green
        case "Calm":
            return Color(red: 0.2, green: 0.6, blue: 0.8)
        case "Energy":
            return Color.orange
        case "Focus":
            return Color(red: 0.6, green: 0.1, blue: 0.3) // Dark pink/maroon
        default:
            return Color.blue
        }
    }
}

// MARK: - Breathing Phase
enum BreathingPhase {
    case inhale
    case hold1
    case exhale
    case hold2
}
