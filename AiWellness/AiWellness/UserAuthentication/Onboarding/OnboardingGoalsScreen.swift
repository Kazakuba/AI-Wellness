import SwiftUI

struct OnboardingGoalsScreen: View {
    @Binding var selectedGoals: Set<String>
    let goals: [(String, String)]
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(spacing: 24) {
                Text("What are your goals?")
                    .font(.title.bold())
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: 16) {
                    ForEach(goals, id: \.1) { icon, label in
                        GoalToggle(icon: icon, label: label, isSelected: selectedGoals.contains(label)) {
                            withAnimation(.spring()) {
                                if selectedGoals.contains(label) {
                                    selectedGoals.remove(label)
                                } else {
                                    selectedGoals.insert(label)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(OnboardingGradients.cardBackground)
            )
            .shadow(color: Color("CustomPrimary").opacity(0.1), radius: 16, x: 0, y: 8)
            .padding(.horizontal, 16)
            Spacer(minLength: 0)
        }
    }
}