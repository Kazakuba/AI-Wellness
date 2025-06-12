// Entry point for Affirmations tab, launches the main AffirmationsView
import SwiftUI

struct AffirmationsEntryView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var hasOpenedAffirmations = false
    var body: some View {
        AffirmationsView(hasOpenedAffirmations: $hasOpenedAffirmations, isDarkMode: isDarkMode)
    }
}
