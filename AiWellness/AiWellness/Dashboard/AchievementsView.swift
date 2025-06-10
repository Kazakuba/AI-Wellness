import SwiftUI

struct AchievementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Unlockable milestones for specific actions will be shown here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            // TODO: List achievements dynamically
            ForEach(0..<3) { i in
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Achievement #\(i+1)")
                        .font(.body)
                }
            }
        }
        .padding(.vertical)
    }
}
