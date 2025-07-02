import SwiftUI

struct AchievementsHorizontalScrollView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showInfoSheet = false
    @State private var selectedAchievement: Achievement? = nil
    @State private var animateGradient = false
    var showAchievementSheet: Binding<Bool> {
        Binding(
            get: { selectedAchievement != nil },
            set: { newValue in if !newValue { selectedAchievement = nil } }
        )
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.leading, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gamification.achievements) { ach in
                        Button(action: {
                            selectedAchievement = ach
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: ach.systemImage)
                                    .font(.system(size: 28))
                                    .foregroundColor(ach.isUnlocked ? (isDarkMode ? .yellow : Color(red: 0.635, green: 0.349, blue: 1.0)) : (isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)))
                                Text(ach.title)
                                    .font(.caption)
                                    .foregroundColor(ach.isUnlocked ? (isDarkMode ? .white : .black) : (isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .lineLimit(1)
                                if !ach.isUnlocked {
                                    ProgressView(value: Float(ach.progress), total: Float(ach.goal))
                                        .frame(width: 60)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.635, green: 0.349, blue: 1.0)))
                                }
                            }
                            .frame(width: 90, height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: isDarkMode ?
                                                [Color.indigo.opacity(0.5), Color.black.opacity(0.5)] :
                                                [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.8, blue: 0.6)]
                                            ),
                                            startPoint: animateGradient ? .topLeading : .topTrailing,
                                            endPoint: animateGradient ? .bottomTrailing : .bottom
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .halfSheet(isPresented: showAchievementSheet) {
            VStack(spacing: 24) {
                if let ach = selectedAchievement {
                    Text(ach.title)
                        .font(.title2).bold()
                        .padding(.top, 16)
                    Text(ach.isUnlocked ? "You unlocked this achievement!" : ach.description)
                        .font(.body)
                        .foregroundColor(ach.isUnlocked ? Color(red: 0.635, green: 0.349, blue: 1.0) : .primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    let clampedProgress = min(max(ach.progress, 0), ach.goal)
                    ProgressView(value: Float(clampedProgress), total: Float(ach.goal))
                        .progressViewStyle(LinearProgressViewStyle(tint: ach.isUnlocked ? Color(red: 0.635, green: 0.349, blue: 1.0) : Color(red: 0.635, green: 0.349, blue: 1.0)))
                        .frame(width: 180, height: 12)
                        .background(Color.gray.opacity(0.15).cornerRadius(6))
                        .padding(.top, 12)
                    Text("Progress: \(clampedProgress)/\(ach.goal)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    AchievementsHorizontalScrollView()
}
