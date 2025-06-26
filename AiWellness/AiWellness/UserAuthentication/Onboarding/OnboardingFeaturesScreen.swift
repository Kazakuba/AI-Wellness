import SwiftUI

struct OnboardingFeaturesScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome to AiWellness!")
                .font(.title.bold())
                .padding(.top, 32)
            VStack(spacing: 20) {
                HStack(spacing: 32) {
                    featureIcon("quote.bubble.fill", "Affirmations")
                    featureIcon("brain.head.profile", "AI Chat")
                }
                HStack(spacing: 32) {
                    featureIcon("book.closed.fill", "Journal")
                    featureIcon("wind", "Breathe")
                }
                featureIcon("clock.arrow.circlepath", "Time Capsule")
            }
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: Color.accentColor.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
} 