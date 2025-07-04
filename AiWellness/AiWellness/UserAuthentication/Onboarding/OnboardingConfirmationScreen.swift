import SwiftUI

struct OnboardingConfirmationScreen: View {
    @Environment(\.colorScheme) var colorScheme
    let selectedGoals: Set<String>
    let dailyAffirmation: Bool
    let streaks: Bool
    let journaling: Bool
    @State private var animateGradient = false

    var body: some View {
        VStack(spacing: 32) {
            Text("You're ready to begin your growth journey!")
                .font(.title.bold())
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.center)
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your goals:")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))

                    if selectedGoals.isEmpty {
                        Text("No goals selected.")
                            .foregroundColor(Color("TextSecondary"))
                    } else {
                        ForEach(Array(selectedGoals), id: \.self) { goal in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color("CustomPrimary").opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("CustomPrimary"))
                                        .font(.system(size: 18))
                                }
                                Text(goal)
                                    .foregroundColor(Color("TextPrimary"))
                            }
                        }
                    }
                }

                Divider()
                    .background(Color("CustomSecondary").opacity(0.3))

                VStack(alignment: .leading, spacing: 16) {
                    Text("Notifications:")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))

                    if !dailyAffirmation && !streaks && !journaling {
                        Text("No notifications enabled.")
                            .foregroundColor(Color("TextSecondary"))
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if dailyAffirmation {
                                notificationRow("bell.badge.fill", "Daily affirmation")
                            }
                            if streaks {
                                notificationRow("flame.fill", "Streak reminders")
                            }
                            if journaling {
                                notificationRow("book.fill", "Journaling nudges")
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Gradients.onboardingCardBackground(colorScheme: colorScheme))
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Gradients.onboardingAnimatedOverlay(animateGradient: animateGradient))
                        .blendMode(.plusLighter)
                        .opacity(0.7)
                        .animation(Animation.linear(duration: 5.0).repeatForever(autoreverses: true), value: animateGradient)
                }
            )
            .shadow(color: Color("CustomPrimary").opacity(0.1), radius: 16, x: 0, y: 8)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 32)
        .onAppear {
            animateGradient.toggle()
        }
    }

    private func notificationRow(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("CustomPrimary"))
            Text(title)
                .foregroundColor(Color("TextPrimary"))
        }
    }
}
