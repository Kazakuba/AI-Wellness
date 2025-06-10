import SwiftUI

struct BadgesHorizontalScrollView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showInfoSheet = false
    @State private var infoTitle = ""
    @State private var infoDescription = ""
    @State private var infoCompleted = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Badges")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.leading, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gamification.badges) { badge in
                        Button(action: {
                            infoTitle = badge.title
                            infoDescription = badge.level > 0 ? "You unlocked this badge!" : badge.description
                            infoCompleted = badge.level > 0
                            showInfoSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: badge.systemImage)
                                    .font(.system(size: 28))
                                    .foregroundColor(badge.level > 0 ? (badge.level == 3 ? .yellow : badge.level == 2 ? .blue : .green) : (isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)))
                                Text(badge.title)
                                    .font(.caption)
                                    .foregroundColor(badge.level > 0 ? (isDarkMode ? .white : .black) : (isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .lineLimit(1)
                                if badge.level == 0 {
                                    ProgressView(value: Float(badge.progress), total: Float(badge.goal))
                                        .frame(width: 60)
                                } else {
                                    Text("Lvl \(badge.level)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
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
                    Text("Complete to earn XP and unlock this badge!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

#Preview {
    BadgesHorizontalScrollView()
}
