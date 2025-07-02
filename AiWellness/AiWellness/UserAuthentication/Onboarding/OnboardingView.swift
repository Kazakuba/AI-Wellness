import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
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
    @State private var dailyAffirmation = false
    @State private var streaks = false
    @State private var journaling = false
    
    var body: some View {
        ZStack {
            // Adaptive gradient background
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color("CustomPrimary").opacity(0.18),
                    Color("CustomSecondary").opacity(0.15),
                    Color(.systemBackground).opacity(0.95)
                ] : [
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
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.63, green: 0.35, blue: 1.0), // Rich purple
                                        Color(red: 1.0, green: 0.65, blue: 0.4)    // Rich orange
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ).opacity(currentStep > 0 ? 0.95 : 0.3)
                            )
                            .cornerRadius(12)
                            .shadow(color: currentStep > 0 ? Color.purple.opacity(0.18) : .clear, radius: 6, x: 0, y: 2)
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
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.63, green: 0.35, blue: 1.0),
                                            Color(red: 1.0, green: 0.65, blue: 0.4)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ).opacity(0.95)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.purple.opacity(0.18), radius: 6, x: 0, y: 2)
                        }
                    } else {
                        Button(action: { completeOnboarding() }) {
                            Text("Finish")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.63, green: 0.35, blue: 1.0),
                                            Color(red: 1.0, green: 0.65, blue: 0.4)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ).opacity(0.95)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.purple.opacity(0.18), radius: 6, x: 0, y: 2)
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
        // Save notification preferences
        UserDefaults.standard.set(dailyAffirmation, forKey: "dailyAffirmationEnabled")
        UserDefaults.standard.set(streaks, forKey: "streaksEnabled")
        UserDefaults.standard.set(journaling, forKey: "journalingEnabled")

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