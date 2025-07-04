import SwiftUI

struct OnboardingNotificationsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var dailyAffirmation: Bool
    @Binding var streaks: Bool
    @Binding var journaling: Bool
    
    @State private var animateGradient = false
    
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
                .onChange(of: dailyAffirmation) { _, newValue in scheduleNotifications(for: "dailyAffirmation", isEnabled: newValue) }
                
                Toggle(isOn: $streaks) {
                    Text("Stay on track with your streaks")
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 8)
                .onChange(of: streaks) { _, newValue in scheduleNotifications(for: "streaks", isEnabled: newValue) }
                
                Toggle(isOn: $journaling) {
                    Text("Helpful nudges for journaling or reflection")
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 8)
                .onChange(of: journaling) { _, newValue in scheduleNotifications(for: "journaling", isEnabled: newValue) }
            }
            .toggleStyle(ColoredToggleStyle())
            .padding(.bottom, 16)
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Gradients.onboardingCardBackground(colorScheme: colorScheme))
                // Animated gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(Gradients.onboardingAnimatedOverlay(animateGradient: animateGradient))
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

    private func scheduleNotifications(for type: String, isEnabled: Bool) {
        let center = UNUserNotificationCenter.current()

        if !isEnabled {
            let identifier: String
            switch type {
            case "dailyAffirmation": identifier = "dailyAffirmationReminder"
            case "streaks": identifier = "streakReminder"
            case "journaling": identifier = "journalingReminder"
            default: return
            }
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            return
        }

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                schedule(type: type)

            case .notDetermined:
                NotificationService.shared.requestPermission { granted in
                    if granted {
                        schedule(type: type)
                    } else {
                        DispatchQueue.main.async {
                            toggleBinding(for: type, to: false)
                        }
                    }
                }
            
            case .denied:
                DispatchQueue.main.async {
                    NotificationService.shared.promptToEnableNotifications()
                    toggleBinding(for: type, to: false)
                }

            @unknown default:
                DispatchQueue.main.async {
                    toggleBinding(for: type, to: false)
                }
            }
        }
    }

    private func schedule(type: String) {
        switch type {
        case "dailyAffirmation":
            NotificationService.shared.scheduleDailyAffirmationReminder()
        case "streaks":
            NotificationService.shared.scheduleStreakReminder()
        case "journaling":
            NotificationService.shared.scheduleJournalingReminder()
        default:
            break
        }
    }

    private func toggleBinding(for type: String, to value: Bool) {
        switch type {
        case "dailyAffirmation":
            dailyAffirmation = value
        case "streaks":
            streaks = value
        case "journaling":
            journaling = value
        default:
            break
        }
    }
}
