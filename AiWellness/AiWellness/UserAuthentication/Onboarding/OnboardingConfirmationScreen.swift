import SwiftUI

struct OnboardingConfirmationScreen: View {
    let selectedGoals: Set<String>
    let dailyAffirmation: Bool
    let streaks: Bool
    let journaling: Bool
    var body: some View {
        VStack(spacing: 32) {
            Text("You're ready to begin your growth journey!")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            VStack(alignment: .leading, spacing: 16) {
                Text("Your goals:")
                    .font(.headline)
                if selectedGoals.isEmpty {
                    Text("No goals selected.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(selectedGoals), id: \.self) { goal in
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                            Text(goal)
                        }
                    }
                }
                Divider()
                Text("Notifications:")
                    .font(.headline)
                if dailyAffirmation { Text("• Daily affirmation") }
                if streaks { Text("• Streak reminders") }
                if journaling { Text("• Journaling nudges") }
                if !dailyAffirmation && !streaks && !journaling {
                    Text("No notifications enabled.")
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: Color.accentColor.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
} 