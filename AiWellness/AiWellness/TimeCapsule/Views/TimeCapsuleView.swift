//
//  TimeCapsuleView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//
import SwiftUI
import Lottie

struct TimeCapsuleView: View {
    @Binding var isPresented: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var viewModel = TimeCapsuleViewModel()
    @State private var animateEntry = false
    @State private var showTimeframeConfirmation = false
    @State private var animateBG = false
    @State private var selectedNote: TimeCapsuleNote? = nil
    @State private var showNoteSheet: Bool = false
    @State private var showLockedSheet: Bool = false
    @State private var lockedCountdown: String = ""
    @State private var countdownTimer: Timer? = nil

    // Helper to dismiss keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack {
            AnimatedNeonBackground(isDarkMode: isDarkMode, animate: $animateBG)
                .edgesIgnoringSafeArea(.all)
            GeometricOverlay()
                .opacity(0.12)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 24) {
                header
                Spacer()
                VStack(spacing: 24) {
                    title
                    LottieView(animation: .named("timeCapsuleLoopAnimation"))
                        .playing()
                        .looping()
                        
                        .frame(width: 200, height: 200)
                        .padding(.vertical, 8)

                    noteInput
                    timeframePicker
                    saveButton
                }
                .background(
                    Color.clear
                )
                allNotesList
                Spacer()
            }
            .padding()
            .opacity(animateEntry ? 1 : 0)
            .offset(y: animateEntry ? 0 : 40)
            .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animateEntry)
            .onAppear {
                animateEntry = true
                animateBG = true
                viewModel.fetchNote()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.checkNotificationAuthorizationAndDismissIfGranted()
                    viewModel.fetchNote()
                }
            }
            .sheet(isPresented: $viewModel.showNotificationPrompt) {
                NotificationReminderPromptView(
                    onSettingsTap: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    onDismiss: {
                        viewModel.showNotificationPrompt = false
                    }
                )
            }
            .alert(isPresented: $showTimeframeConfirmation) {
                Alert(
                    title: Text("Lock Note?"),
                    message: Text("Your message will unlock in \(viewModel.selectedTimeframe). Continue?"),
                    primaryButton: .default(Text("Yes, Lock It")) {
                        viewModel.confirmAndSaveNote(dismissKeyboard: dismissKeyboard)
                    },
                    secondaryButton: .cancel(Text("Change Timeframe"))
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TimeCapsuleNoteTapped"))) { _ in
                viewModel.fetchNote()
                if let lastNote = viewModel.savedNotes.last {
                    viewModel.noteToPresent = lastNote
                    viewModel.showUnlockedNote = true
                    HapticManager.trigger(.success)
                }
            }
            // Sheet for note (locked or unlocked)
            .sheet(item: $selectedNote, onDismiss: {
                countdownTimer?.invalidate()
                countdownTimer = nil
            }) { note in
                VStack(spacing: 24) {
                    if note.unlockDate <= Date() {
                        Text("Your Note")
                            .font(Typography.Font.heading2)
                            .padding(.top)
                        Text(note.content)
                            .font(Typography.Font.body1)
                            .padding()
                    } else {
                        Text("Locked Note")
                            .font(Typography.Font.heading2)
                            .padding(.top)
                        Text("This note will unlock in")
                            .font(Typography.Font.body1)
                        Text(lockedCountdown)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                            .padding(.vertical, 8)
                    }
                    Button("Close") { selectedNote = nil }
                        .padding()
                        .foregroundColor(.black)
                }
                .onAppear {
                    if note.unlockDate > Date() {
                        startCountdownTimer(for: note)
                    }
                }
                .onDisappear {
                    countdownTimer?.invalidate()
                    countdownTimer = nil
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private var header: some View {
        HStack {
            IconButton(icon: "xmark", title: "") {
                isPresented = false
            }
            Spacer()
        }
    }
    
    private var title: some View {
        Text("Write A Note To Your Future Self ")
            .font(Typography.Font.heading2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .shadow(color: Color.cyan.opacity(0.7), radius: 8, x: 0, y: 0)
            //.padding(.top, 8)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing)
                    .mask(Text("Write A Note To Your Future Self ").font(Typography.Font.heading2).fontWeight(.bold))
                    .opacity(0.7)
            )
    }
    
    private var noteInput: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                .background(Color.clear)
            TextFieldComponent(text: $viewModel.noteContent , placeholder: "Type your note here...")
                .padding(12)
                .foregroundColor(.white)
        }
        .frame(height: 48)
    }
    
    private var timeframePicker: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                .background(Color.clear)
            Picker("Select Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(viewModel.timeframes, id: \.self) { timeframe in
                    Text(timeframe).tag(timeframe)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
    }
    
    private var saveButton: some View {
        Button(action: { showTimeframeConfirmation = true }) {
            Text("Save Note")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(16)
                .shadow(color: Color.cyan.opacity(0.5), radius: 8, x: 0, y: 0)
        }
    }
    
    private var allNotesList: some View {
        let now = Date()
        return Group {
            if viewModel.savedNotes.isEmpty {
                Text("No notes yet.")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 16)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.savedNotes.sorted(by: { $0.unlockDate > $1.unlockDate })) { note in
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    selectedNote = note
                                    if note.unlockDate > now {
                                        lockedCountdown = timeRemainingString(until: note.unlockDate)
                                    }
                                }) {
                                    if note.unlockDate <= now {
                                        Text(note.content)
                                            .font(Typography.Font.body1)
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color.purple.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            )
                                    } else {
                                        Text("🔒 This note will unlock on \(note.unlockDate, formatter: DateFormatter.short)")
                                            .font(Typography.Font.body1)
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(12)
                                            .background(
                                                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.08), Color.purple.opacity(0.08)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            )
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .frame(maxHeight: 260)
            }
        }
    }
    
    private var actions: some View { EmptyView() }
    
    // Helper for time remaining string
    private func timeRemainingString(until date: Date) -> String {
        let now = Date()
        let interval = Int(date.timeIntervalSince(now))
        if interval <= 0 { return "0 seconds" }
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        var parts: [String] = []
        if days > 0 { parts.append("\(days)d") }
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 { parts.append("\(minutes)m") }
        if seconds > 0 { parts.append("\(seconds)s") }
        return parts.joined(separator: " ")
    }

    private func startCountdownTimer(for note: TimeCapsuleNote) {
        countdownTimer?.invalidate()
        lockedCountdown = timeRemainingString(until: note.unlockDate)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            lockedCountdown = timeRemainingString(until: note.unlockDate)
            if Date() >= note.unlockDate {
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
        }
    }
}


#Preview {
    TimeCapsuleView(isPresented: .constant(true))
}

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemGray4), Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct AnimatedNeonBackground: View {
    var isDarkMode: Bool
    @Binding var animate: Bool
    @State private var animateGradient = false
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: animate ? [Color.cyan, Color.purple, Color.blue, Color.mint] : [ColorPalette.background, ColorPalette.surface]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(Animation.linear(duration: 6).repeatForever(autoreverses: true), value: animate)
    }
}

struct GeometricOverlay: View {
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                Circle()
                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                    .frame(width: CGFloat(120 + i*40), height: CGFloat(120 + i*40))
                    .offset(x: CGFloat(i*10), y: CGFloat(i*10))
            }
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 24)
                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.12), Color.cyan.opacity(0.08)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                    .frame(width: CGFloat(220 + i*60), height: CGFloat(80 + i*30))
                    .offset(x: CGFloat(-i*20), y: CGFloat(i*30))
            }
        }
    }
}

struct GlowingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                    .shadow(color: Color.cyan.opacity(configuration.isPressed ? 0.2 : 0.7), radius: configuration.isPressed ? 6 : 16, x: 0, y: 0)
            )
            .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

