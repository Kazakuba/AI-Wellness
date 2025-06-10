import SwiftUI

struct GamifiedDashboardHeaderView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showResetAlert = false
    @State private var showInfoSheet = false
    @State private var infoTitle = ""
    @State private var infoDescription = ""
    @State private var infoCompleted = false
    // Placeholder values for now
    var level: Int = 3
    var currentXP: Int = 120
    var nextLevelXP: Int = 200
    var dailyStreak: Int = 0
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level \(gamification.level)")
                    .font(.title2).bold()
                    .foregroundColor(isDarkMode ? .white : .black)
                Button(action: { showResetAlert = true }) {
                    Text("[X]")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                .alert(isPresented: $showResetAlert) {
                    Alert(title: Text("Reset Progress?"), message: Text("This will clear all achievements, badges, XP, and level for this user."), primaryButton: .destructive(Text("Reset")) {
                        gamification.resetAll()
                    }, secondaryButton: .cancel())
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(0) days") // TODO: Connect streak
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(gradient: Gradient(colors: isDarkMode ? [Color.indigo.opacity(0.7), Color.black.opacity(0.7)] : [Color.mint.opacity(0.7), Color.cyan.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                )
            }
            .padding(.horizontal, 8)
            // XP Progress Bar
            XPProgressBar(currentXP: gamification.xp, nextLevelXP: gamification.level * 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: isDarkMode ? [Color.indigo.opacity(0.5), Color.black.opacity(0.5)] : [Color.mint.opacity(0.5), Color.cyan.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .padding(.horizontal)
    }
}

struct XPProgressBar: View {
    var currentXP: Int
    var nextLevelXP: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(currentXP) / CGFloat(nextLevelXP) * 220, height: 14)
                    .animation(.easeInOut, value: currentXP)
            }
            HStack {
                Text("XP: \(currentXP)/\(nextLevelXP)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}

#Preview {
    GamifiedDashboardHeaderView()
}
