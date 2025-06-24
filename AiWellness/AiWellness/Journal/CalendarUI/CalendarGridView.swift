// CalendarGridView.swift
// AiWellness
// Extracted from CalendarView.swift

import SwiftUI

struct CalendarGridView: View {
    let monthOffset: Int
    let today: Date
    @Binding var currentMonthOffset: Int
    var onDateSelected: (Date) -> Void
    var isDarkMode: Bool

    static let minMonthOffset = -12
    static let maxMonthOffset = 12

    var body: some View {
        let days = generateDaysForMonth(offset: monthOffset)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
            ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                Text(day)
                    .foregroundColor(isDarkMode ? .white : .black)
            }

            ForEach(days.indices, id: \.self) { index in
                let day = days[index]
                if day == 0 {
                    Text("") // Empty cell for leading spaces
                } else if let date = getDateForDay(day: day, offset: monthOffset) {
                    let hasContent = WritingDataManager.shared.hasContent(for: date)
                    let isCurrentDay = isToday(day: day, offset: monthOffset)

                    Text("\(day)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(10)
                        .background(isCurrentDay ? Color.red : Color.clear) // Red circle for today
                        .clipShape(Circle())
                        .foregroundColor(
                            isCurrentDay ? Color.white :
                            (isDarkMode ? (hasContent ? Color.green : Color.white) : (hasContent ? Color.green : Color.black))
                        )
                        .onTapGesture {
                            onDateSelected(date)
                        }
                }
            }
        }
    }

    private func getDateForDay(day: Int, offset: Int) -> Date? {
        guard let adjustedDate = Calendar.current.date(byAdding: .month, value: offset, to: self.today) else {
            return nil
        }
        var components = Calendar.current.dateComponents([.year, .month], from: adjustedDate)
        components.day = day
        return Calendar.current.date(from: components)
    }

    private func isToday(day: Int, offset: Int) -> Bool {
        guard day > 0 else { return false }
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: self.today) else { return false }
        let visibleMonth = calendar.component(.month, from: visibleDate)
        let visibleYear = calendar.component(.year, from: visibleDate)
        let todayComponents = calendar.dateComponents([.day, .month, .year], from: self.today)
        return day == todayComponents.day && visibleMonth == todayComponents.month && visibleYear == todayComponents.year
    }

    private func generateDaysForMonth(offset: Int) -> [Int] {
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: self.today) else { return [] }
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleDate)) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1 // 1=Sunday
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: visibleDate)?.count else { return [] }
        let leadingEmptyDays = (firstWeekday + 6) % 7
        var days: [Int] = []
        days.append(contentsOf: Array(repeating: 0, count: leadingEmptyDays))
        days.append(contentsOf: Array(1...daysInMonth))
        return days
    }
}
