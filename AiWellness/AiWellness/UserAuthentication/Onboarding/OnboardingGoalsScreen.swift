import SwiftUI

struct OnboardingGoalsScreen: View {
    @Binding var selectedGoals: Set<String>
    let goals: [(String, String)]
    let currentStep: Int
    let totalSteps: Int
    var body: some View {
        VStack(spacing: 24) {
            Text("What are your goals?")
                .font(.title.bold())
                .padding(.top, 32)
            Text("Select all that apply")
                .font(.subheadline)
                .foregroundColor(.secondary)
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
            ProgressView(value: Double(currentStep+1), total: Double(totalSteps))
                .padding(.top, 16)
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: Color.accentColor.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
} 