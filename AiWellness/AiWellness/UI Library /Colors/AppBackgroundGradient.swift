import SwiftUI

public struct AppBackgroundGradient {
    public static func main(_ isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.indigo, Color.black] :
                [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
