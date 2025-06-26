import SwiftUI

struct OnboardingFeaturesScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome to AiWellness!")
                .font(.title.bold())
                .foregroundColor(Color("TextPrimary"))
                .padding(.top, 32)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 24) {
                featureRow("quote.bubble.fill", "Affirmations")
                featureRow("brain.head.profile", "AI Chat")
                featureRow("book.fill", "Journal")
                featureRow("wind", "Breathe")
                featureRow("clock.arrow.circlepath", "Time Capsule")
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(OnboardingGradients.cardBackground)
        )
        .shadow(color: Color("CustomPrimary").opacity(0.1), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }

    private func featureRow(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.system(size: 30))
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
