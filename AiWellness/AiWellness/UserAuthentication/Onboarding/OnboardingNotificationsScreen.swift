import SwiftUI

struct OnboardingNotificationsScreen: View {
    @Binding var dailyAffirmation: Bool
    @Binding var streaks: Bool
    @Binding var journaling: Bool
    var body: some View {
        VStack(spacing: 32) {
            Text("Stay motivated with notifications")
                .font(.title.bold())
                .padding(.top, 32)
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: $dailyAffirmation) {
                    Text("Receive your daily affirmation")
                }
                Toggle(isOn: $streaks) {
                    Text("Stay on track with your streaks")
                }
                Toggle(isOn: $journaling) {
                    Text("Helpful nudges for journaling or reflection")
                }
            }
            .toggleStyle(ColoredToggleStyle())
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: Color.accentColor.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
} 