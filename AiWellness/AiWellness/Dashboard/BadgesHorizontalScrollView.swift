import SwiftUI

struct BadgesHorizontalScrollView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @State private var showInfoSheet = false
    @State private var selectedBadge: Badge? = nil

    var showBadgeSheet: Binding<Bool> {
        Binding(
            get: { selectedBadge != nil },
            set: { newValue in if !newValue { selectedBadge = nil } }
        )
    }
    
    // Badge color based on level
    private func badgeColor(for level: Int) -> Color {
        switch level {
        case 1: return .orange // Bronze
        case 2: return .gray // Silver
        case 3: return .yellow // Gold
        default: return isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5) // Locked
        }
    }
    
    // Badge level text
    private func badgeLevelText(for level: Int) -> String {
        switch level {
        case 1: return "Bronze"
        case 2: return "Silver"
        case 3: return "Gold"
        default: return "Locked"
        }
    }

    // Helper to get the next milestone for a badge
    private func nextMilestone(for badge: Badge) -> Int {
        let milestones = badge.milestones ?? [badge.goal]
        let idx = min(badge.level, milestones.count - 1)
        return milestones[idx]
    }

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
                            selectedBadge = badge
                            showInfoSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: badge.systemImage)
                                    .font(.system(size: 28))
                                    .foregroundColor(badgeColor(for: badge.level))
                                Text(badge.title)
                                    .font(.caption)
                                    .foregroundColor(badge.level > 0 ? (isDarkMode ? .white : .black) : (isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .lineLimit(1)
                                if badge.level == 0 {
                                    let milestone = nextMilestone(for: badge)
                                    let clampedProgress = min(max(badge.progress, 0), milestone)
                                    ProgressView(value: Float(clampedProgress), total: Float(milestone))
                                        .frame(width: 60)
                                } else {
                                    Text(badgeLevelText(for: badge.level))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(badgeColor(for: badge.level))
                                        .cornerRadius(4)
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
                                            startPoint: .topTrailing,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )}
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .halfSheet(isPresented: showBadgeSheet) {
            VStack(spacing: 24) {
                if let badge = selectedBadge {
                    Text(badge.title)
                        .font(.title2).bold()
                        .padding(.top, 16)
                    
                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    // Level Up! badge: show milestone progress
                    if badge.id == "level_up" {
                        let milestones = [2, 5, 10, 20, 100]
                        let currentLevel = gamification.level
                        let nextMilestone = milestones.first(where: { $0 > currentLevel })
                        if let next = nextMilestone {
                            let clampedLevel = min(max(currentLevel, 0), next)
                            ProgressView(value: Float(clampedLevel), total: Float(next))
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .frame(width: 180, height: 12)
                                .background(Color.gray.opacity(0.15).cornerRadius(6))
                                .padding(.top, 12)
                            Text("Progress to next milestone (Lvl \(next)): \(clampedLevel)/\(next)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 16)
                        } else {
                            Text("All milestones reached!")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.top, 12)
                        }
                    } else if badge.level > 0 {
                        let milestone = nextMilestone(for: badge)
                        let clampedProgress = min(max(badge.progress, 0), milestone)
                        ProgressView(value: Float(clampedProgress), total: Float(milestone))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(width: 180, height: 12)
                            .background(Color.gray.opacity(0.15).cornerRadius(6))
                            .padding(.top, 12)
                        Text("Progress to next level: \(clampedProgress)/\(milestone)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                        Text("Current Level: \(badgeLevelText(for: badge.level))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        let milestone = nextMilestone(for: badge)
                        let clampedProgress = min(max(badge.progress, 0), milestone)
                        ProgressView(value: Float(clampedProgress), total: Float(milestone))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(width: 180, height: 12)
                            .background(Color.gray.opacity(0.15).cornerRadius(6))
                            .padding(.top, 12)
                        Text("Progress: \(clampedProgress)/\(milestone)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    BadgesHorizontalScrollView()
}
