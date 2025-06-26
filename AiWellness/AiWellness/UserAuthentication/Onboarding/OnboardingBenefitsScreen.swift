import SwiftUI

struct OnboardingBenefitsScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("What's in it for you?")
                .font(.title.bold())
                .foregroundColor(Color("TextPrimary"))
                .padding(.top, 32)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 24) {
                benefitRow("sparkles", "Reinforce positive mindset")
                    .transition(.slide)
                
                benefitRow("chart.bar.xaxis", "Track personal growth")
                    .transition(.slide)
                
                benefitRow("flame.fill", "Stay consistent with streaks & rewards")
                    .transition(.slide)
                
                benefitRow("person.crop.circle.badge.checkmark", "Personalized experience based on your goals")
                    .transition(.slide)
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
}
