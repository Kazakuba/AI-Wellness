import SwiftUI

struct OnboardingGoalsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedGoals: Set<String>
    let goals: [(String, String)]
    let currentStep: Int
    let totalSteps: Int
    @State private var animateGradient = false
    
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
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(OnboardingGradients.cardBackground(for: colorScheme))
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
            Spacer(minLength: 0)
        }
    }
}
