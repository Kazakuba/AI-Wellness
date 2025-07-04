import SwiftUI
import ConfettiSwiftUI

struct GamifiedDashboardHeaderView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showResetAlert = false
    @State private var showResetFlagsAlert = false
    @State private var showInfoSheet = false
    @State private var infoTitle = ""
    @State private var infoDescription = ""
    @State private var infoCompleted = false
    @State private var dailyStreak: Int = 0
    @State private var confettiTrigger: Int = 0
    @State private var lastCelebratedLevel: Int = 1
    @State private var animateGradient = false
    var level: Int = 3
    var currentXP: Int = 120
    var nextLevelXP: Int = 200
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level \(gamification.level)")
                    .font(.title2).bold()
                    .foregroundColor(isDarkMode ? .white : .black)

                /*
                Button(action: { showResetAlert = true }) {
                    Text("[X]")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                .alert(isPresented: $showResetAlert) {
                    Alert(title: Text("Reset Progress?"), message: Text("This will clear all achievements, badges, XP, and level for this user."), primaryButton: .destructive(Text("Reset")) {
                        gamification.resetAll()
                        updateStreak()
                    }, secondaryButton: .cancel())
                }
                Button(action: { showResetFlagsAlert = true }) {
                    Text("[F]")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                .alert(isPresented: $showResetFlagsAlert) {
                    Alert(title: Text("Reset Achievement Flags?"), message: Text("This will reset all achievement flags, allowing you to unlock achievements again for testing."), primaryButton: .destructive(Text("Reset Flags")) {
                        gamification.resetAchievementFlags()
                    }, secondaryButton: .cancel())
                }
                Button(action: {
                    if let uid = GamificationManager.shared.getUserUID() {
                        let key = "onboarding_completed_\(uid)"
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                    NotificationCenter.default.post(name: Notification.Name("RestartOnboarding"), object: nil)
                }) {
                    Text("[R]")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                */

                Spacer()
                HStack(spacing: 6) {
                    Gradients.dashboardFlameGradient
                        .frame(width: 28, height: 28)
                        .mask(
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                    Text("\(dailyStreak) days")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Gradients.dashboardCardBackground(isDarkMode: isDarkMode, animate: animateGradient))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 13)

            XPProgressBar(currentXP: gamification.xp, nextLevelXP: gamification.level * 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Gradients.dashboardCardBackground(isDarkMode: isDarkMode))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
        .confettiCannon(trigger: $confettiTrigger, num: 40, colors: [.yellow, .green, .blue, .orange])
        .onAppear {
            updateStreak()
            let uid = gamification.getUserUID() ?? "default"
            let lastLevelKey = "lastCelebratedLevel_\(uid)"
            let defaults = UserDefaults.standard
            let storedLevel = defaults.integer(forKey: lastLevelKey)
            lastCelebratedLevel = storedLevel > 0 ? storedLevel : gamification.level
            if gamification.level > lastCelebratedLevel {
                ConfettiManager.shared.celebrate()
                lastCelebratedLevel = gamification.level
                defaults.set(lastCelebratedLevel, forKey: lastLevelKey)
            }
            let speed = max(0.5, 3.0 - Double(dailyStreak) * 0.1)
            withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
        .onChange(of: gamification.level) { oldLevel, newLevel in
            let uid = gamification.getUserUID() ?? "default"
            let lastLevelKey = "lastCelebratedLevel_\(uid)"
            let defaults = UserDefaults.standard
            if newLevel > lastCelebratedLevel {
                ConfettiManager.shared.celebrate()
                lastCelebratedLevel = newLevel
                defaults.set(lastCelebratedLevel, forKey: lastLevelKey)
            }
        }
    }

    private func updateStreak() {
        let uid = gamification.getUserUID() ?? "default"
        let streakKey = "app_open_streak_\(uid)"
        let lastDateKey = "app_open_streak_last_\(uid)"
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: lastDateKey) as? Date
        var streak = defaults.integer(forKey: streakKey)
        if let last = lastDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            if days == 1 {
                streak += 1
            } else if days > 1 {
                streak = 1
            } else {
                streak = 1
            }
            defaults.set(today, forKey: lastDateKey)
            defaults.set(streak, forKey: streakKey)
            dailyStreak = streak
        }
    }

    struct XPProgressBar: View {
        var currentXP: Int
        var nextLevelXP: Int
        @AppStorage("isDarkMode") var isDarkMode: Bool = false
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 14)
                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.65, blue: 0.4),
                                                                         Color(red: 1.0, green: 0.45, blue: 0.4)]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: CGFloat(currentXP) / CGFloat(nextLevelXP) * 220, height: 14)
                        .animation(.easeInOut, value: currentXP)
                }
                HStack {
                    Text("XP: \(currentXP)/\(nextLevelXP)")
                        .font(.caption)
                        .foregroundColor(isDarkMode ? .white : .black)
                    Spacer()
                }
            }
        }
    }
}
