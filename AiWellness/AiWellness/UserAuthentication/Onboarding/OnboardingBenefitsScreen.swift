import SwiftUI

struct OnboardingBenefitsScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("What's in it for you?")
                .font(.title.bold())
                .padding(.top, 32)
            VStack(alignment: .leading, spacing: 20) {
                benefitRow("sparkles", "Reinforce positive mindset")
                benefitRow("chart.bar.xaxis", "Track personal growth")
                benefitRow("flame.fill", "Stay consistent with streaks & rewards")
                benefitRow("person.crop.circle.badge.checkmark", "Personalized experience based on your goals")
            }
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: Color.accentColor.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
} 