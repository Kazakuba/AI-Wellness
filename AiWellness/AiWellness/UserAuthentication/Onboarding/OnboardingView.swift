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
            // Beautiful gradient background
            LinearGradient(
                colors: [
                    Color("CustomPrimary").opacity(0.15),
                    Color("CustomSecondary").opacity(0.1),
                    Color.white.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative shapes for visual interest
            Circle()
                .fill(Color("CustomPrimary").opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color("CustomSecondary").opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 150, y: 300)
            
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
                HStack(spacing: 10) {
                    ForEach(0..<totalSteps, id: \.self) { idx in
                        Circle()
                            .fill(idx == currentStep ? Color("CustomPrimary") : Color("CustomSecondary").opacity(0.3))
                            .frame(width: idx == currentStep ? 12 : 10, height: idx == currentStep ? 12 : 10)
                            .animation(.spring(), value: currentStep)
                            .overlay(
                                Circle()
                                    .stroke(idx == currentStep ? Color("CustomPrimary").opacity(0.3) : Color.clear, lineWidth: 2)
                                    .scaleEffect(1.3)
                            )
                    }
                }
                .padding(.vertical, 8)
                
                // Navigation
                HStack {
                    Button(action: { if currentStep > 0 { currentStep -= 1 } }) {
                        Text("Back")
                            .foregroundColor(currentStep > 0 ? .white : Color.white.opacity(0.7))
                            .fontWeight(.bold)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(currentStep > 0 ? Color("CustomPrimary") : Color("CustomPrimary").opacity(0.3))
                            .cornerRadius(12)
                            .shadow(color: currentStep > 0 ? Color("CustomPrimary").opacity(0.18) : .clear, radius: 6, x: 0, y: 2)
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
                                .background(Color("CustomPrimary"))
                                .cornerRadius(12)
                                .shadow(color: Color("CustomPrimary").opacity(0.18), radius: 6, x: 0, y: 2)
                        }
                    } else {
                        Button(action: { completeOnboarding() }) {
                            Text("Finish")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Color("CustomPrimary"))
                                .cornerRadius(12)
                                .shadow(color: Color("CustomPrimary").opacity(0.18), radius: 6, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
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