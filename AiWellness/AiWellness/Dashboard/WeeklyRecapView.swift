import SwiftUI

struct WeeklyRecapView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly highlights: XP gained, streaks, top affirmation, new badges/level.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            // TODO: Show weekly recap data
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Week of June 11, 2025")
                    .font(.body)
            }
        }
        .padding(.vertical)
    }
}
