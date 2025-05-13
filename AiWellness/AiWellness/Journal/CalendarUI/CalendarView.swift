//
//  CalendarView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24.
//

import SwiftUI
import Foundation
import LocalAuthentication

struct CalendarView: View {
    @State private var currentMonthOffset = 0
    @State private var isButtonDisabled = false // Prevent rapid presses
    @State private var isManuallyChangingMonth = false // Track manual button usage
    @State private var selectedDate: IdentifiableDate?
    @State private var isUnlocked = false
    @State private var showAuthFailedAlert = false
    @State private var showBiometricUnavailableAlert = false
    @State private var journalUserChangeObserver: NSObjectProtocol? = nil

    @Environment(\.scenePhase) private var scenePhase

    @Binding var selectedTab: Int

    let futureMonthsToShow = 6
    private let today = Date()

    struct IdentifiableDate: Identifiable {
        let id = UUID()
        let date: Date
    }

    var body: some View {
        let monthRange = calculateMonthRange()
        VStack {
            if selectedTab == 2 {
                if isUnlocked {
                    // Main Calendar View
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
                                .disabled(isButtonDisabled || currentMonthOffset <= monthRange.lowerBound)

                                TertiaryButton(title: "Today", action: {
                                    moveToToday()
                                })
                                .disabled(isButtonDisabled)

                                IconButton(icon: "chevron.right", title: nil) {
                                    changeMonth(by: 1)
                                }
                                .disabled(isButtonDisabled || currentMonthOffset >= monthRange.upperBound)
                            }
                        }
                        .padding()

                        // Scrollable calendar
                        GeometryReader { geometry in
                            ScrollView(.vertical) {
                                ScrollViewReader { proxy in
                                    VStack(spacing: 30) {
                                        Spacer()
                                            .frame(height: 50)
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
                } else {
                    // Placeholder view before authentication
                    VStack {
                        Image ("lockedScreen")
                            .resizable()
                            .ignoresSafeArea()
                    }

                }
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == 2 {
                // User switched *to* the Calendar tab
                if !isUnlocked {
                    authenticate()
                }
            } else {
                // User left the Calendar tab => lock it
                isUnlocked = false
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                // If user returns to foreground *and* is on Calendar tab but not unlocked yet, authenticate
                if selectedTab == 2 && !isUnlocked {
                    authenticate()
                }
            case .inactive, .background:
                // Lock only if user is on Calendar tab
                if selectedTab == 2 {
                    isUnlocked = false
                }
            @unknown default:
                break
            }
        }
        .alert(
            "No Biometric/Passcode Enabled",
            isPresented: $showBiometricUnavailableAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enable Face ID, Touch ID, or a device passcode in Settings to protect your Journal.")
        }
        .alert(
            "Authentication Failed",
            isPresented: $showAuthFailedAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't verify your identity. Please try again.")
        }
        .onAppear {
            // Listen for user change to refresh notes
            journalUserChangeObserver = NotificationCenter.default.addObserver(forName: Notification.Name("journalUserDidChange"), object: nil, queue: .main) { _ in
                selectedDate = nil // Dismiss any open note
                currentMonthOffset = 0 // Reset to today
            }
        }
        .onDisappear {
            if let observer = journalUserChangeObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if device supports Face ID, Touch ID, or passcode
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access your calendar"

            // Use deviceOwnerAuthentication to support biometrics + passcode fallback
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Unlock the view if authentication is successful
                        self.isUnlocked = true
                    } else {
                        // Authentication failed
                        self.isUnlocked = false
                        self.selectedTab = 0
                        self.showAuthFailedAlert = true
                    }
                }
            }
        } else {
            // Neither biometrics nor passcode available
            DispatchQueue.main.async {
                self.isUnlocked = false
                self.selectedTab = 0
                self.showBiometricUnavailableAlert = true
            }
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
        let earliestDate = WritingDataManager.shared.earliestNoteDate() ?? today
        return earliestDate
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
        let monthRange = calculateMonthRange()
        guard !isButtonDisabled else { return }
        let newOffset = currentMonthOffset + offset
        // Prevent changing month outside of visible range
        guard newOffset >= monthRange.lowerBound && newOffset <= monthRange.upperBound else { return }
        isManuallyChangingMonth = true
        isButtonDisabled = true // Disable button temporarily
        withAnimation {
            currentMonthOffset = newOffset
        }
        // Re-enable buttons after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isButtonDisabled = false
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(2))
}
