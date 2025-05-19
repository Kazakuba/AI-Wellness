// Entry point for Affirmations tab, launches the main AffirmationsView
import SwiftUI

struct AffirmationsEntryView: View {
    @State private var hasOpenedAffirmations = false
    var body: some View {
        AffirmationsView(hasOpenedAffirmations: $hasOpenedAffirmations)
    }
}
