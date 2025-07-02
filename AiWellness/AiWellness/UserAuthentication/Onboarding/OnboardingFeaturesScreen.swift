import SwiftUI

struct OnboardingFeaturesScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animateGradient = false

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
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(OnboardingGradients.cardBackground(for: colorScheme))
                // Animated gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.18), Color("CustomPrimary").opacity(0.12), Color.purple.opacity(0.18)]),
                            startPoint: animateGradient ? .topLeading : .bottomTrailing,
                            endPoint: animateGradient ? .bottomTrailing : .topLeading
                        )
                    )
                    .blendMode(.plusLighter)
                    .opacity(0.7)
                    .animation(Animation.linear(duration: 5.0).repeatForever(autoreverses: true), value: animateGradient)
            }
        )
        .shadow(color: Color("CustomPrimary").opacity(0.1), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
        .onAppear {
            animateGradient.toggle()
        }
    }

    private func featureRow(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.635, green: 0.349, blue: 1.0))
                .font(.system(size: 30))
                .shadow(color: Color(red: 0.635, green: 0.349, blue: 1.0).opacity(0.5), radius: 8, x: 0, y: 0)
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
