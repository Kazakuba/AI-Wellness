//
//  TimeCapsuleView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//
import SwiftUI

struct TimeCapsuleView: View {
    @Binding var isPresented: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = TimeCapsuleViewModel()
    @State private var animateEntry = false
    @State private var showTimeframeConfirmation = false

    var body: some View {
        ZStack {
            ((isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all))
                .opacity(animateEntry ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: animateEntry)
            
            VStack(spacing: 20) {
                header
                
                Spacer()
                VStack(spacing: 20) {
                    title
                    noteInput
                    timeframePicker
                    saveButton
                }
                
                Spacer()
                
                actions
            }
            .padding()
            .onAppear {
                animateEntry = true
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.checkNotificationAuthorizationAndDismissIfGranted()
                }
            }
            .sheet(isPresented: $viewModel.showSavedNotes) {
                SavedCapsuleNotesView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showArchivedNotes) {
                ArchivedNotesView(viewModel: viewModel)
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
                                    viewModel.confirmAndSaveNote()
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
             .foregroundColor(isDarkMode ? .white : .black)
    }
    
    private var noteInput: some View {
        TextFieldComponent(text: $viewModel.noteContent , placeholder: "Type your note here...")
            .padding()
            .foregroundColor(isDarkMode ? .white : .black)
    }
    
    private var timeframePicker: some View {
        Picker("Select Timeframe", selection: $viewModel.selectedTimeframe) {
            ForEach(viewModel.timeframes, id: \.self) { timeframe in
                Text(timeframe).tag(timeframe)
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(ColorPalette.buttonBackground)
            .cornerRadius(10)
        }
    }
    
    private var saveButton: some View {
        PrimaryButton(title: "Save Note") {
            showTimeframeConfirmation = true
        }
        .buttonStyle(GlowingButtonStyle())
    }
    
    private var actions: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "View Saved Notes") {
                viewModel.showSavedNotes = true
            }
            .buttonStyle(GlowingButtonStyle())
            
            PrimaryButton(title: "View Archived Notes") {
                viewModel.showArchivedNotes = true
            }
            .buttonStyle(GlowingButtonStyle())
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

struct GlowingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.cyan)
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(color: Color.cyan.opacity(configuration.isPressed ? 0.3 : 0.8),
                    radius: configuration.isPressed ? 10 : 20,
                    x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

