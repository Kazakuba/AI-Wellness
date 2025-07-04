import SwiftUI

struct WeeklyRecapView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var gamification = GamificationManager.shared
    @StateObject private var savedAffirmations = SavedAffirmationViewModel()
    @State private var currentStatIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var showFullRecap = false
    @ObservedObject private var chatStore = ChatStore.shared
    
    private var weekStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
    }
    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
    }
    
    private var xpThisWeek: Int {
        gamification.xp
    }
    private var currentStreak: Int {
        gamification.badges.first(where: { $0.id == "consistency" })?.progress ?? 0
    }
    private var newBadges: [Badge] {
        gamification.badges.filter { $0.level > 0 }
    }
    private var affirmationsThisWeek: Int {
        savedAffirmations.savedAffirmations.filter { $0.date >= weekStart && $0.date < weekEnd }.count
    }
    private var breathingSessionsThisWeek: Int {
        let uid = gamification.getUserUID() ?? "default"
        let key = "breathwork_pro_sessions_timestamps_\(uid)"
        if let data = UserDefaults.standard.data(forKey: key),
           let timestamps = try? JSONDecoder().decode([Date].self, from: data) {
            return timestamps.filter { $0 >= weekStart && $0 < weekEnd }.count
        } else {
            let count = UserDefaults.standard.integer(forKey: "breathwork_pro_sessions_\(uid)")
            return count
        }
    }
    private var journalEntriesThisWeek: Int {
        guard let uid = gamification.getUserUID() else { return 0 }
        let entries = WritingDataManager.shared
            .loadAllEntries(for: uid)
            .filter { $0.key >= weekStart && $0.key < weekEnd && !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return entries.count
    }
    private var aiChatsThisWeek: Int {
        chatStore.chats.flatMap { chat in
            chat.messages.filter { $0.timestamp >= weekStart && $0.timestamp < weekEnd && $0.sender == "Me" }
        }.count
    }
    
    private func iconColor(for stat: String) -> Color {
        switch stat {
        case "star.fill": return isDarkMode ? Color.yellow : Color.orange
        case "flame.fill": return isDarkMode ? Color.orange : Color.red
        case "heart.fill": return isDarkMode ? Color.pink : Color.pink
        case "rosette": return getBadgeColor()
        case "lungs.fill": return isDarkMode ? Color.mint : Color.teal
        case "book.closed.fill": return isDarkMode ? Color.blue : Color.indigo
        case "message.fill": return isDarkMode ? Color.green : Color.green
        case "calendar": return isDarkMode ? .white : .black
        default: return isDarkMode ? .white : .black
        }
    }
    
    private func getBadgeColor() -> Color {
        if let badge = newBadges.randomElement() {
            switch badge.level {
            case 1: return Color("Achievement-Bronze")
            case 2: return Color("Achievement-Silver")
            case 3: return Color("Achievement-Gold")
            default: return isDarkMode ? .white : .black
            }
        }
        return isDarkMode ? .white : .black
    }
    
    private var stats: [(icon: String, title: String, value: String, color: Color)] {
        var arr: [(String, String, String, Color)] = []
        arr.append(("star.fill", "XP Gained", "\(xpThisWeek)", iconColor(for: "star.fill")))
        arr.append(("flame.fill", "Current Streak", "\(currentStreak) days", iconColor(for: "flame.fill")))
        arr.append(("heart.fill", "Affirmations Saved", "\(affirmationsThisWeek)", iconColor(for: "heart.fill")))
        arr.append(("lungs.fill", "Breathing Sessions", "\(breathingSessionsThisWeek)", iconColor(for: "lungs.fill")))
        arr.append(("book.closed.fill", "Journal Entries", "\(journalEntriesThisWeek)", iconColor(for: "book.closed.fill")))
        arr.append(("message.fill", "AI Chats", "\(aiChatsThisWeek)", iconColor(for: "message.fill")))
        if let badge = newBadges.randomElement() {
            arr.append((badge.systemImage, "New Badge/Level", badge.title + " (" + badgeLevelText(for: badge.level) + ")", iconColor(for: "rosette")))
        }
        return arr
    }
    
    var dashboardGradient: LinearGradient {
        Gradients.dashboardCardBackground(isDarkMode: isDarkMode)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(dashboardGradient)
                .shadow(color: isDarkMode ? Color.black.opacity(0.2) : Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(iconColor(for: "calendar"))
                    Text("Weekly Recap")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    Spacer()
                    Text("\(weekStart, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                if !stats.isEmpty {
                    recapCard(icon: stats[currentStatIndex].icon, title: stats[currentStatIndex].title, value: stats[currentStatIndex].value, color: stats[currentStatIndex].color)
                        .transition(.opacity)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .onAppear {
            savedAffirmations.loadSavedAffirmations()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onTapGesture {
            showFullRecap = true
        }
        .sheet(isPresented: $showFullRecap) {
            FullWeeklyRecapSheet(
                weekStart: weekStart,
                xp: xpThisWeek,
                streak: currentStreak,
                affirmationsThisWeek: affirmationsThisWeek,
                breathingSessions: breathingSessionsThisWeek,
                journalEntries: journalEntriesThisWeek,
                aiChats: aiChatsThisWeek,
                newBadges: newBadges,
                isDarkMode: isDarkMode,
                iconColor: iconColor
            )
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation {
                if !stats.isEmpty {
                    currentStatIndex = Int.random(in: 0..<stats.count)
                }
            }
        }
    }
    
    private func recapCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                Text(value)
                    .font(.body)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .padding()
    }
    
    private func badgeLevelText(for level: Int) -> String {
        switch level {
        case 1: return "Bronze"
        case 2: return "Silver"
        case 3: return "Gold"
        default: return "Locked"
        }
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    private func getBadgeColorForLevel(_ level: Int) -> Color {
        switch level {
        case 1:
            return Color("Achievement-Bronze")
        case 2:
            return Color("Achievement-Silver")
        case 3:
            return Color("Achievement-Gold")
        default:
            return isDarkMode ? .white : .black
        }
    }
}

struct FullWeeklyRecapSheet: View {
    let weekStart: Date
    let xp: Int
    let streak: Int
    let affirmationsThisWeek: Int
    let breathingSessions: Int
    let journalEntries: Int
    let aiChats: Int
    let newBadges: [Badge]
    let isDarkMode: Bool
    let iconColor: (String) -> Color
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    var dashboardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ? [Color.indigo, Color.black] : [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(iconColor("calendar"))
                Text("Weekly Recap")
                    .font(.title2).bold()
                    .foregroundColor(isDarkMode ? .white : .black)
                Spacer()
                Text("\(weekStart, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 50)
            recapCard(icon: "star.fill", title: "XP Gained", value: "\(xp)", color: iconColor("star.fill"))
            recapCard(icon: "flame.fill", title: "Current Streak", value: "\(streak) days", color: iconColor("flame.fill"))
            recapCard(icon: "heart.fill", title: "Affirmations Saved", value: "\(affirmationsThisWeek)", color: iconColor("heart.fill"))
            recapCard(icon: "lungs.fill", title: "Breathing Sessions", value: "\(breathingSessions)", color: iconColor("lungs.fill"))
            recapCard(icon: "book.closed.fill", title: "Journal Entries", value: "\(journalEntries)", color: iconColor("book.closed.fill"))
            recapCard(icon: "message.fill", title: "AI Chats", value: "\(aiChats)", color: iconColor("message.fill"))
            if !newBadges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "rosette")
                            .foregroundColor(iconColor("rosette"))
                        Text("Achievements & Badges")
                            .font(.headline)
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(newBadges) { badge in
                                VStack(spacing: 4) {
                                    Image(systemName: badge.systemImage)
                                        .font(.system(size: 28))
                                        .foregroundColor(getBadgeColorForLevel(badge.level))
                                    Text(badge.title)
                                        .font(.caption)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity)
                                    Text(badgeLevelText(for: badge.level))
                                        .font(.caption2)
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(width: 80, height: 80)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
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
                                )
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(dashboardGradient)
                .shadow(color: isDarkMode ? Color.black.opacity(0.25) : Color.gray.opacity(0.12), radius: 16, x: 0, y: 8)
        )
    }
    private func recapCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                Text(value)
                    .font(.body)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .padding()
    }
    private func badgeLevelText(for level: Int) -> String {
        switch level {
        case 1: return "Bronze"
        case 2: return "Silver"
        case 3: return "Gold"
        default: return "Locked"
        }
    }
    private func getBadgeColorForLevel(_ level: Int) -> Color {
        switch level {
        case 1:
            return Color("Achievement-Bronze")
        case 2:
            return Color("Achievement-Silver")
        case 3:
            return Color("Achievement-Gold")
        default:
            return isDarkMode ? .white : .black
        }
    }
}
