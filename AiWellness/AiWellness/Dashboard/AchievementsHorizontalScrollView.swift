import SwiftUI

struct AchievementsHorizontalScrollView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showInfoSheet = false
    @State private var infoTitle = ""
    @State private var infoDescription = ""
    @State private var infoCompleted = false
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
                            infoTitle = ach.title
                            infoDescription = ach.isUnlocked ? "You unlocked this achievement!" : ach.description
                            infoCompleted = ach.isUnlocked
                            showInfoSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: ach.systemImage)
                                    .font(.system(size: 28))
                                    .foregroundColor(ach.isUnlocked ? (isDarkMode ? .yellow : .green) : (isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)))
                                Text(ach.title)
                                    .font(.caption)
                                    .foregroundColor(ach.isUnlocked ? (isDarkMode ? .white : .black) : (isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .lineLimit(1)
                                if !ach.isUnlocked {
                                    ProgressView(value: Float(ach.progress), total: Float(ach.goal))
                                        .frame(width: 60)
                                }
                            }
                            .frame(width: 90, height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(gradient: Gradient(colors: isDarkMode ? [Color.indigo.opacity(0.25), Color.black.opacity(0.18)] : [Color.mint.opacity(0.18), Color.cyan.opacity(0.18)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .halfSheet(isPresented: $showInfoSheet) {
            VStack(spacing: 20) {
                Text(infoTitle)
                    .font(.title2).bold()
                Text(infoDescription)
                    .font(.body)
                    .foregroundColor(infoCompleted ? .green : .primary)
                if !infoCompleted {
                    Text("Complete to earn XP and unlock this achievement!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

#Preview {
    AchievementsHorizontalScrollView()
}
