import SwiftUI
import Foundation

struct CalendarViewHelpers {
    static func getMonthYear(for offset: Int, today: Date) -> String {
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: today) else { return "Invalid Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: visibleDate)
    }

    static func opacityForMonth(innerGeometry: GeometryProxy, parentGeometry: GeometryProxy) -> Double {
        let centerY = parentGeometry.frame(in: .global).midY
        let offsetY = abs(innerGeometry.frame(in: .global).midY - centerY)
        let maxDistance = parentGeometry.size.height / 2
        return max(0.3, 1 - (offsetY / maxDistance))
    }

    static func earliestMonthWithNotes(today: Date) -> Date {
        let earliestDate = WritingDataManager.shared.earliestNoteDate() ?? today
        return earliestDate
    }

    static func calculateMonthRange(today: Date, futureMonthsToShow: Int) -> ClosedRange<Int> {
        let calendar = Calendar.autoupdatingCurrent
        let earliestDate = earliestMonthWithNotes(today: today)
        let components = calendar.dateComponents([.year, .month, .day], from: earliestDate, to: today)
        var earliestOffset = (components.year ?? 0) * 12 + (components.month ?? 0)
        if let earliestDay = calendar.dateComponents([.day], from: earliestDate).day,
           let todayDay = calendar.dateComponents([.day], from: today).day,
           earliestDay > todayDay {
            earliestOffset += 1
        }
        return -earliestOffset...futureMonthsToShow
    }
} 