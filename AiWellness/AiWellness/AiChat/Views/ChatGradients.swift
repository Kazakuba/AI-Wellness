import SwiftUI

struct ChatGradients {
    static func mainBackground(_ isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.indigo, Color.black] :
                [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static func sectionBackground(_ isDarkMode: Bool, opacity: Double = 0.3) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.white.opacity(opacity), Color.white.opacity(opacity - 0.1)] :
                [Color.white.opacity(opacity + 0.1), Color.white.opacity(opacity)]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var userBubble: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var aiBubble: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
} 