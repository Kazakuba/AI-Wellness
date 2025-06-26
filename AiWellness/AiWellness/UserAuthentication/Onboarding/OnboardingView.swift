import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    let totalSteps = 5
    let onFinish: () -> Void
    
    // Step 3: Goals
    @State private var selectedGoals: Set<String> = []
    let goals = [
        ("heart.fill", "Build a daily self-love habit"),
        ("face.smiling", "Improve emotional balance"),
        ("wind", "Stay calm and present"),
        ("sun.max.fill", "Cultivate gratitude"),
        ("waveform.path.ecg", "Reduce anxiety")
    ]
    
    // Step 4: Notifications
    @State private var dailyAffirmation = true
    @State private var streaks = true
    @State private var journaling = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.25), Color.blue.opacity(0.12), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack {
                TabView(selection: $currentStep) {
                    OnboardingFeaturesScreen()
                        .tag(0)
                    OnboardingBenefitsScreen()
                        .tag(1)
                    OnboardingGoalsScreen(selectedGoals: $selectedGoals, goals: goals, currentStep: currentStep, totalSteps: totalSteps)
                        .tag(2)
                    OnboardingNotificationsScreen(dailyAffirmation: $dailyAffirmation, streaks: $streaks, journaling: $journaling)
                        .tag(3)
                    OnboardingConfirmationScreen(selectedGoals: selectedGoals, dailyAffirmation: dailyAffirmation, streaks: streaks, journaling: journaling)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                .frame(maxHeight: .infinity)
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { idx in
                        Circle()
                            .fill(idx == currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.vertical, 8)
                // Navigation
                HStack {
                    Button(action: { if currentStep > 0 { currentStep -= 1 } }) {
                        Text("Back")
                            .foregroundColor(currentStep > 0 ? .white : Color.white.opacity(0.5))
                            .fontWeight(.bold)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(currentStep > 0 ? Color.accentColor : Color.accentColor.opacity(0.3))
                            .cornerRadius(10)
                            .shadow(color: currentStep > 0 ? Color.accentColor.opacity(0.25) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .disabled(currentStep == 0)
                    Spacer()
                    if currentStep < totalSteps - 1 {
                        Button(action: { currentStep += 1 }) {
                            Text("Next")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                                .shadow(color: Color.accentColor.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                    } else {
                        Button(action: { completeOnboarding() }) {
                            Text("Finish")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                                .shadow(color: Color.accentColor.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.bottom, 24)
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
    }
    
    private func completeOnboarding() {
        if let uid = GamificationManager.shared.getUserUID() {
            let key = "onboarding_completed_\(uid)"
            UserDefaults.standard.set(true, forKey: key)
        }
        print("Onboarding complete, calling onFinish()...")
        DispatchQueue.main.async {
            onFinish()
        }
    }
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinish: {})
    }
} 