// Main AffirmationsView with locked/unlocked states and UI
import SwiftUI

struct AffirmationsView: View {
    @Binding var hasOpenedAffirmations: Bool
    var isDarkMode: Bool = false
    @StateObject private var viewModel = AffirmationsViewModel()
    @StateObject private var savedViewModel = SavedAffirmationViewModel()
    @StateObject private var motionManager = MotionManager()
    @State private var showThemeSheet = false
    @State private var showTodayAffirmation: Bool = false
    @State private var todayAffirmation: Affirmation?
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeLibrary.defaultTheme.id

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ? [Color.indigo, Color.black] : [Color.mint, Color.cyan]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button(action: { viewModel.showSavedSheet = true }) {
                        Image(systemName: "bookmark.fill")
                            .font(.title2)
                            .padding()
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                }
                Spacer()
                if viewModel.isLocked {
                    Spacer()
                    VStack(spacing: 24) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                            .opacity(viewModel.showUnlockAnimation ? 0.5 : 1.0)
                            .scaleEffect(viewModel.showUnlockAnimation ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.6), value: viewModel.showUnlockAnimation)
                        Text("Unlock your daily affirmation!")
                            .font(.title2)
                            .foregroundColor(.black)
                            .opacity(viewModel.showUnlockAnimation ? 0.5 : 1.0)
                            .animation(.easeInOut(duration: 0.6), value: viewModel.showUnlockAnimation)
                        if viewModel.showUnlockAnimation {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Button(action: {
                            viewModel.unlockAffirmation()
                            handleAffirmationUnlock()
                        }) {
                            Text("Shake or Tap to Unlock")
                                .font(.headline)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(24)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        .accessibilityIdentifier("unlockButton")
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.7))
                            .shadow(radius: 16)
                    )
                    .padding(.horizontal, 24)
                    .offset(y: -90)
                    .transition(.opacity.combined(with: .scale))
                    Spacer()
                } else if let affirmation = viewModel.dailyAffirmation {
                    Spacer()
                    let theme = ThemeLibrary.allThemes.first(where: { $0.id == selectedThemeId }) ?? ThemeLibrary.defaultTheme
                    Text(affirmation.text)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    Spacer()
                    HStack(spacing: 40) {
                        Button(action: {
                            let text = affirmation.text
                            let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                av.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                                    guard completed else { return }
                                    // --- Sharing logic ---
                                    let uid = GamificationManager.shared.getUserUID() ?? "default"
                                    let shareKey = "sharing_is_caring_count_\(uid)"
                                    let defaults = UserDefaults.standard
                                    let previousShareCount = defaults.integer(forKey: shareKey)
                                    let newShareCount = previousShareCount + 1
                                    defaults.set(newShareCount, forKey: shareKey)
                                    // Increment achievement progress by 1 for each share
                                    GamificationManager.shared.incrementAchievement("sharing_is_caring", by: 1)
                                    // Update badge progress using milestone-based system
                                    GamificationManager.shared.incrementBadge("social_sharer", by: 1)
                                    // --- First Share achievement (share at least once) ---
                                    if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "first_share" }) {
                                        if !GamificationManager.shared.achievements[idx].isUnlocked {
                                            GamificationManager.shared.achievements[idx].progress = 1
                                            GamificationManager.shared.achievements[idx].isUnlocked = true
                                        }
                                    }
                                    GamificationManager.shared.save()
                                }
                                rootVC.present(av, animated: true, completion: nil)
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 28))
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                viewModel.saveAffirmation(affirmation)
                            }
                        }) {
                            Image(systemName: viewModel.savedAffirmations.contains(where: { $0.text == affirmation.text }) ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.top, 16)
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { viewModel.showTopicSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.grid.2x2")
                                Text(viewModel.selectedTopic?.title ?? "January affirmations")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(theme.isDark ? .white : Color(red: 44/255, green: 51/255, blue: 71/255))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(isDarkMode ? Color.white.opacity(0.18) : Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        Spacer()
                        Button(action: { showThemeSheet = true }) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 22))
                                .foregroundColor(isDarkMode ? .white : .black)
                                .frame(width: 48, height: 48)
                        }
                        .background(isDarkMode ? Color.white.opacity(0.18) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        Button(action: {}) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 22))
                                .foregroundColor(isDarkMode ? .white : .black)
                                .frame(width: 48, height: 48)
                        }
                        .background(isDarkMode ? Color.white.opacity(0.18) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .sheet(isPresented: $viewModel.showSavedSheet) {
                SavedAffirmationView(viewModel: savedViewModel)
            }
            .sheet(isPresented: $viewModel.showTopicSheet) {
                TopicSelectionSheet(isPresented: $viewModel.showTopicSheet, selectedTopic: $viewModel.selectedTopic, topics: AffirmationTopicsProvider.topics) { topic in
                    viewModel.selectTopic(topic)
                }
            }
            .sheet(isPresented: $showThemeSheet) {
                ThemePickerSheet(isPresented: $showThemeSheet)
            }
            .onAppear {
                // Always lock on tab open (not on topic change)
                viewModel.isLocked = true
            }
            .onChange(of: motionManager.didShake) { _, didShake in
                if didShake && viewModel.isLocked {
                    viewModel.unlockAffirmation()
                    handleAffirmationUnlock(fromShake: true)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveAffirmationNotification)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.loadDailyAffirmation()
                    showTodayAffirmation = true
                }
            }
        }
    }

    private func handleAffirmationUnlock(fromShake: Bool = false) {
        if fromShake {
            GamificationManager.shared.incrementAchievement("shake_it_up")
            GamificationManager.shared.incrementBadge("shaker")
        }
        // --- Streak logic ---
        let uid = GamificationManager.shared.getUserUID() ?? "default"
        let streakKey = "affirmation_streak_\(uid)"
        let lastDateKey = "affirmation_streak_last_\(uid)"
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
            } else if days == 0 {
                // Already unlocked today, do not increment streak
            }
        } else {
            streak = 1
        }
        defaults.set(today, forKey: lastDateKey)
        defaults.set(streak, forKey: streakKey)
        // Update achievement and badge progress directly
        if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "streak_starter" }) {
            GamificationManager.shared.achievements[idx].progress = streak
            GamificationManager.shared.achievements[idx].isUnlocked = (streak >= 3)
        }
        // Update badge progress using milestone-based system
        GamificationManager.shared.incrementBadge("consistency")
        // --- Streak Slayer badge ---
        if let idx = GamificationManager.shared.badges.firstIndex(where: { $0.id == "streak_slayer" }) {
            GamificationManager.shared.badges[idx].progress = streak
            if streak == 3 || streak == 7 || streak == 30 {
                GamificationManager.shared.badges[idx].level = min(3, GamificationManager.shared.badges[idx].level + 1)
            }
        }
        // --- Affirmation Streak achievement (7-day streak) ---
        if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "affirmation_streak" }) {
            GamificationManager.shared.achievements[idx].progress = streak
            GamificationManager.shared.achievements[idx].isUnlocked = (streak >= 7)
        }
        GamificationManager.shared.save()
    }
}
