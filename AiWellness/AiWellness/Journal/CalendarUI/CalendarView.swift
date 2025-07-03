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
    @State private var isButtonDisabled = false
    @State private var isManuallyChangingMonth = false
    @State private var selectedDate: IdentifiableDate?
    @State private var isUnlocked = false
    @State private var showAuthFailedAlert = false
    @State private var showBiometricUnavailableAlert = false
    @State private var journalUserChangeObserver: NSObjectProtocol? = nil

    @Environment(\.scenePhase) private var scenePhase

    @Binding var selectedTab: Int
    var isDarkMode: Bool = false
    @AppStorage("isDarkMode") var appStorageDarkMode: Bool = false

    let futureMonthsToShow = 6
    private let today = Date()

    struct IdentifiableDate: Identifiable {
        let id = UUID()
        let date: Date
    }

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.indigo, Color.black] :
                                [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            AppBackgroundGradient.main(isDarkMode).ignoresSafeArea()
            VStack {
                if selectedTab == 2 {
                    if isUnlocked {
                        let monthRange = CalendarViewHelpers.calculateMonthRange(today: today, futureMonthsToShow: futureMonthsToShow)
                        VStack(spacing: 10) {
                            HStack {
                                Text(CalendarViewHelpers.getMonthYear(for: currentMonthOffset, today: today))
                                    .font(Typography.Font.heading2)
                                    .foregroundColor(appStorageDarkMode ? .white : .black)

                                Spacer()

                                HStack(spacing: 20) {
                                    IconButton(icon: "chevron.left", title: nil) {
                                        changeMonth(by: -1)
                                    }
                                    .disabled(isButtonDisabled || currentMonthOffset <= monthRange.lowerBound)

                                    TertiaryButton(title: "Today", action: {
                                        moveToToday()
                                    })
                                    .foregroundColor(appStorageDarkMode ? .white : .black)
                                    .disabled(isButtonDisabled)

                                    IconButton(icon: "chevron.right", title: nil) {
                                        changeMonth(by: 1)
                                    }
                                    .disabled(isButtonDisabled || currentMonthOffset >= monthRange.upperBound)
                                }
                            }
                            .padding()

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
                                                        },
                                                        isDarkMode: appStorageDarkMode
                                                    )
                                                    .frame(height: geometry.size.height / 3)
                                                    .opacity(CalendarViewHelpers.opacityForMonth(innerGeometry: innerGeometry, parentGeometry: geometry))
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
                        VStack {
                            Image ("lockedScreen")
                                .resizable()
                                .ignoresSafeArea()
                        }

                    }
                }
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == 2 {
                if !isUnlocked {
                    authenticate()
                }
            } else {
                isUnlocked = false
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                if selectedTab == 2 && !isUnlocked {
                    authenticate()
                }
            case .inactive, .background:
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
            journalUserChangeObserver = NotificationCenter.default.addObserver(forName: Notification.Name("journalUserDidChange"), object: nil, queue: .main) { _ in
                selectedDate = nil
                currentMonthOffset = 0
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

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access your calendar"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.isUnlocked = false
                        self.selectedTab = 0
                        self.showAuthFailedAlert = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isUnlocked = false
                self.selectedTab = 0
                self.showBiometricUnavailableAlert = true
            }
        }
    }

    private func updateCurrentMonth(innerGeometry: GeometryProxy, offset: Int, parentGeometry: GeometryProxy) {
        guard !isManuallyChangingMonth else { return }

        let centerY = parentGeometry.frame(in: .global).midY
        let viewMidY = innerGeometry.frame(in: .global).midY
        let threshold: CGFloat = parentGeometry.size.height / 4

        if abs(viewMidY - centerY) < threshold, currentMonthOffset != offset {
            currentMonthOffset = offset
        }
    }

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
        let earliestDate = earliestMonthWithNotes()
        let components = calendar.dateComponents([.year, .month, .day], from: earliestDate, to: today)
        var earliestOffset = (components.year ?? 0) * 12 + (components.month ?? 0)
        if let earliestDay = calendar.dateComponents([.day], from: earliestDate).day,
           let todayDay = calendar.dateComponents([.day], from: today).day,
           earliestDay > todayDay {
            earliestOffset += 1
        }

        return -earliestOffset...futureMonthsToShow
    }

    private func changeMonth(by offset: Int) {
        let monthRange = calculateMonthRange()
        guard !isButtonDisabled else { return }
        let newOffset = currentMonthOffset + offset
        guard newOffset >= monthRange.lowerBound && newOffset <= monthRange.upperBound else { return }
        isManuallyChangingMonth = true
        isButtonDisabled = true
        withAnimation {
            currentMonthOffset = newOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isButtonDisabled = false
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(2))
}
