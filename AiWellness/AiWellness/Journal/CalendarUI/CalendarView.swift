//
//  CalendarView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24.
//

import SwiftUI
import Foundation

struct CalendarView: View {
    @State private var currentMonthOffset = 0
    @State private var isButtonDisabled = false // Prevent rapid presses
    @State private var isManuallyChangingMonth = false // Track manual button usage
    @State private var selectedDate: IdentifiableDate?
    @State private var isViewLoaded = false
    
    let futureMonthsToShow = 6
    private let today = Date()
    
    struct IdentifiableDate: Identifiable {
        let id = UUID()
        let date: Date
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header with title and controls
            HStack {
                Text(getMonthYear(for: currentMonthOffset))
                    .font(Typography.Font.heading2)
                
                Spacer()
                
                HStack(spacing: 20) {
                    IconButton(icon: "chevron.left", title: nil) {
                        changeMonth(by: -1)
                    }
                    .disabled(isButtonDisabled)
                    
                    TertiaryButton(title: "Today", action: {
                        moveToToday()
                    })
                    .disabled(isButtonDisabled)
                    
                    IconButton(icon: "chevron.right", title: nil) {
                        changeMonth(by: 1)
                    }
                    .disabled(isButtonDisabled)
                }
            }
            .padding()
            
            // Scrollable calendar
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 40)
                            ForEach(calculateMonthRange(), id: \.self) { offset in
                                GeometryReader { innerGeometry in
                                    CalendarGridView(
                                        monthOffset: offset,
                                        today: today,
                                        currentMonthOffset: $currentMonthOffset,
                                        onDateSelected: { date in
                                            selectedDate = IdentifiableDate(date: date)
                                        }
                                    )
                                    .frame(height: geometry.size.height / 3) // Adjust grid size
                                    .opacity(opacityForMonth(innerGeometry: innerGeometry, parentGeometry: geometry))
                                    .id(offset)
                                    .onAppear {
                                        updateCurrentMonth(innerGeometry: innerGeometry, offset: offset, parentGeometry: geometry)
                                    }
                                    .onChange(of: innerGeometry.frame(in: .global).midY) {
                                        updateCurrentMonth(innerGeometry: innerGeometry, offset: offset, parentGeometry: geometry)
                                    }
                                }
                                .frame(height: geometry.size.height / 1.8)
                            }
                        }
                        .onAppear {
                            currentMonthOffset = 0
                            withAnimation {
                                proxy.scrollTo(currentMonthOffset, anchor: .center)
                            }
                        }
                        .onChange(of: currentMonthOffset) { _, newValue in
                            if isManuallyChangingMonth {
                                withAnimation {
                                    proxy.scrollTo(newValue, anchor: .center)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isManuallyChangingMonth = false
                                }
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 100
                            if value.translation.height < -threshold {
                                changeMonth(by: 1)
                            } else if value.translation.height > threshold {
                                changeMonth(by: -1)
                            }
                        }
                )
            }
        }
        .padding()
        .sheet(item: $selectedDate) { identifiableDate in
            WritingView(selectedDate: identifiableDate.date)
        }
    }
    
    
    // Helper function to get the visible month and year
    private func getMonthYear(for offset: Int) -> String {
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: today) else { return "Invalid Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: visibleDate)
    }
    
    // Calculate opacity based on proximity to the center of the viewport
    private func opacityForMonth(innerGeometry: GeometryProxy, parentGeometry: GeometryProxy) -> Double {
        let centerY = parentGeometry.frame(in: .global).midY
        let offsetY = abs(innerGeometry.frame(in: .global).midY - centerY)
        let maxDistance = parentGeometry.size.height / 2
        return max(0.3, 1 - (offsetY / maxDistance)) // Max opacity at center
    }
    
    // Update the current month based on which month is closest to the center
    private func updateCurrentMonth(innerGeometry: GeometryProxy, offset: Int, parentGeometry: GeometryProxy) {
        guard !isManuallyChangingMonth else { return }
        
        let centerY = parentGeometry.frame(in: .global).midY
        let viewMidY = innerGeometry.frame(in: .global).midY
        
        let threshold: CGFloat = parentGeometry.size.height / 4
        
        // Only update if the month is within the center threshold
        if abs(viewMidY - centerY) < threshold, currentMonthOffset != offset {
            currentMonthOffset = offset
        }
    }
    
    // Move to today
    private func moveToToday() {
        isManuallyChangingMonth = true
        withAnimation {
            currentMonthOffset = 0
        }
    }
    
    private func earliestMonthWithNotes() -> Date {
        return WritingDataManager.shared.earliestNoteDate() ?? today
    }
    
    private func calculateMonthRange() -> ClosedRange<Int> {
        let calendar = Calendar.autoupdatingCurrent
        
        // Calculate the difference in months between `today` and the earliest note date
        let earliestDate = earliestMonthWithNotes()
        
        // Calculate the month difference and account for days
        let components = calendar.dateComponents([.year, .month, .day], from: earliestDate, to: today)
        var earliestOffset = (components.year ?? 0) * 12 + (components.month ?? 0)
        
        // If the day of the earliestDate is after today's day, include the extra month
        if let earliestDay = calendar.dateComponents([.day], from: earliestDate).day,
           let todayDay = calendar.dateComponents([.day], from: today).day,
           earliestDay > todayDay {
            earliestOffset += 1
        }
        
        // Return a range from the earliest offset to 6 months in the future
        return -earliestOffset...futureMonthsToShow
    }
    
    // Change month by a specific offset
    private func changeMonth(by offset: Int) {
        guard !isButtonDisabled else { return }
        isManuallyChangingMonth = true
        isButtonDisabled = true // Disable button temporarily
        
        let newOffset = currentMonthOffset + offset
        withAnimation {
            currentMonthOffset = newOffset
        }
        
        // Re-enable buttons after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isButtonDisabled = false
        }
    }
}

// Subview for displaying a month's calendar grid
struct CalendarGridView: View {
    let monthOffset: Int
    let today: Date
    @Binding var currentMonthOffset: Int
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        let days = generateDaysForMonth(offset: monthOffset)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
            ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                Text(day)
                    .foregroundColor(ColorPalette.Text.secondary)
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
                        .foregroundColor(isCurrentDay ? Color.white : (hasContent ? Color.green : Color.primary)) // Green for content, white for today's number
                        .onTapGesture {
                            onDateSelected(date)
                        }
                }
            }
        }
    }
    
    private func getDateForDay(day: Int, offset: Int) -> Date? {
        guard let adjustedDate = Calendar.current.date(byAdding: .month, value: offset, to: today) else {
            return nil
        }
        
        var components = Calendar.current.dateComponents([.year, .month], from: adjustedDate)
        components.day = day
        
        return Calendar.current.date(from: components)
    }
    
    private func isToday(day: Int, offset: Int) -> Bool {
        guard day > 0 else { return false }
        
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: today) else { return false }
        let visibleMonth = calendar.component(.month, from: visibleDate)
        let visibleYear = calendar.component(.year, from: visibleDate)
        let todayComponents = calendar.dateComponents([.day, .month, .year], from: today)
        
        return day == todayComponents.day && visibleMonth == todayComponents.month && visibleYear == todayComponents.year
    }
    
    private func generateDaysForMonth(offset: Int) -> [Int] {
        let calendar = Calendar.autoupdatingCurrent
        guard let visibleDate = calendar.date(byAdding: .month, value: offset, to: today) else { return [] }
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
#Preview {
    CalendarView()
}
