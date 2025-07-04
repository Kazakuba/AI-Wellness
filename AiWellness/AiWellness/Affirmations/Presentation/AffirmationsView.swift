// Main AffirmationsView with locked/unlocked states and UI
import SwiftUI
import ConfettiSwiftUI

struct AffirmationsView: View {
    @Binding var hasOpenedAffirmations: Bool
    var isDarkMode: Bool = false
    @StateObject private var viewModel = AffirmationsViewModel()
    @StateObject private var savedViewModel = SavedAffirmationViewModel()
    @StateObject private var motionManager = MotionManager()
    @State private var showTodayAffirmation: Bool = false
    @State private var todayAffirmation: Affirmation?
    @StateObject private var confettiManager = ConfettiManager.shared

    var gradient: LinearGradient {
        Gradients.dashboardMainBackground(isDarkMode: isDarkMode)
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
                            .foregroundColor(isDarkMode ? .white : .black)
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
                                .background(
                                    Gradients.unlockButtonBackground(isDarkMode: isDarkMode)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            Gradients.unlockButtonBorder(isDarkMode: isDarkMode),
                                            lineWidth: 1.5
                                        )
                                )
                                .foregroundColor(isDarkMode ? .white : .black)
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
                                    let uid = GamificationManager.shared.getUserUID() ?? "default"
                                    let shareKey = "sharing_is_caring_count_\(uid)"
                                    let defaults = UserDefaults.standard
                                    let previousShareCount = defaults.integer(forKey: shareKey)
                                    let newShareCount = previousShareCount + 1
                                    defaults.set(newShareCount, forKey: shareKey)
                                    if GamificationManager.shared.incrementBadge("social_sharer", by: 1) {
                                        ConfettiManager.shared.celebrate()
                                    }
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
                            .foregroundColor(isDarkMode ? .white : Color(red: 44/255, green: 51/255, blue: 71/255))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(isDarkMode ? Color.white.opacity(0.18) : Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        Spacer()
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
            .onAppear {
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
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, confettis: confettiManager.confettis, colors: [.yellow, .green, .blue, .orange])
    }

    private func handleAffirmationUnlock(fromShake: Bool = false) {
        if fromShake {
            let uid = GamificationManager.shared.getUserUID() ?? "default"
            let shakeKey = "shake_it_up_\(uid)"
            let defaults = UserDefaults.standard
            let hasShakenBefore = defaults.bool(forKey: shakeKey)
            if !hasShakenBefore {
                defaults.set(true, forKey: shakeKey)
                if GamificationManager.shared.incrementAchievement("shake_it_up") {
                    ConfettiManager.shared.celebrate()
                }
            }
            if GamificationManager.shared.incrementBadge("shaker") {
                ConfettiManager.shared.celebrate()
            }
        }
        let uid = GamificationManager.shared.getUserUID() ?? "default"
        let streakKey = "affirmation_streak_\(uid)"
        let lastDateKey = "affirmation_streak_last_\(uid)"
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: lastDateKey) as? Date

        if let last = lastDate, Calendar.current.isDate(last, inSameDayAs: today) {
            return
        }

        var streak = defaults.integer(forKey: streakKey)

        if let last = lastDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            if days == 1 {
                streak += 1
            } else if days > 1 {
                streak = 1
            }
        } else {
            streak = 1
        }
        
        defaults.set(today, forKey: lastDateKey)
        defaults.set(streak, forKey: streakKey)
        
        GamificationManager.shared.updateConsistencyBadge(streak: streak)
        GamificationManager.shared.save()

        ConfettiManager.shared.celebrate()
    }
}
