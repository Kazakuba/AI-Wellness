// Entry point for Affirmations tab
import SwiftUI
import ConfettiSwiftUI

struct AffirmationsEntryView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var hasOpenedAffirmations = false
    @StateObject private var confettiManager = ConfettiManager.shared
    var body: some View {
        AffirmationsView(hasOpenedAffirmations: $hasOpenedAffirmations, isDarkMode: isDarkMode)
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, colors: [.yellow, .green, .blue, .orange])
    }
}
