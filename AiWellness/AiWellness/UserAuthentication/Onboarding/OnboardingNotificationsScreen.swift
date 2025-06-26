import SwiftUI

struct OnboardingNotificationsScreen: View {
    @Binding var dailyAffirmation: Bool
    @Binding var streaks: Bool
    @Binding var journaling: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Stay motivated with notifications")
                .font(.title.bold())
                .foregroundColor(Color("TextPrimary"))
                .padding(.top, 32)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 24) {
                Toggle(isOn: $dailyAffirmation) {
                    Text("Receive your daily affirmation")
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 8)
                
                Toggle(isOn: $streaks) {
                    Text("Stay on track with your streaks")
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 8)
                
                Toggle(isOn: $journaling) {
                    Text("Helpful nudges for journaling or reflection")
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 8)
            }
            .toggleStyle(ColoredToggleStyle())
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