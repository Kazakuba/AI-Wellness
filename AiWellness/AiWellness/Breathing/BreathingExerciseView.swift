//
//  BreathingExerciseView.swift
//  AiWellness
//
//  Created by Kazakuba on 05.04.25.
//

import SwiftUI

struct BreathingExerciseView: View {
    @StateObject private var viewModel = BreathingExerciseViewModel()
    @State private var showControls = true
    @State private var showText = true
    @State private var showCustomizationSheet = true
    @State private var controlsTimer: Timer? = nil
    @State private var instructionsTimer: Timer? = nil
    @State private var shouldStartAfterDismiss = false
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    // Tab bar visibility control
    @Binding var tabBarHidden: Bool
    
    // Add this state variable near the top of the struct
    @State private var hideControlsTask: DispatchWorkItem? = nil
    
    // Initialize with default parameters for TabView usage
    init(tabBarHidden: Binding<Bool> = .constant(false)) {
        self._tabBarHidden = tabBarHidden
    }
    
    // New property to control dark mode appearance
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            (isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
            
            // Loading overlay - show this immediately before anything else renders
            if showCustomizationSheet {
                // Empty colored background to prevent seeing the animation view
                ColorPalette.background.edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 0) {
                    // Top controls
                    if showControls {
                        HStack {
                            // Back button
                            Button(action: {
                                handleBackButton()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Back")
                                        .font(Typography.Font.body2)
                                }
                                .foregroundColor(isDarkMode ? .white : .black)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            }
                            .padding(.leading, 8)

                            Spacer()
                            
                            Button(action: {
                                showCustomizationSheet = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title2)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .padding()
                            }
                        }
                        .padding(.top, 32)
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: showControls)
                    }
                    
                    // Safe area spacer to avoid instructions overlapping with top notch
                    Spacer().frame(height: 20)
                    
                    // Guided text that appears when exercise starts
                    if showText {
                        Text(viewModel.currentInstructions)
                            .font(Typography.Font.body1)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.06))
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showText)
                    } else if viewModel.isPlaying {
                        // Show the countdown guide when main instructions are hidden
                        VStack(spacing: 8) {
                            // Parse the text to separate the instruction from the number
                            let components = viewModel.countdownText.components(separatedBy: " ")
                            if components.count == 2 {
                                // Instruction text (Inhale, Hold, Exhale)
                                Text(components[0])
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    .padding(.bottom, 5)
                                
                                // Countdown number with animation
                                Text(components[1])
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    .contentTransition(.numericText())
                                    .transaction { transaction in
                                        transaction.animation = .easeInOut(duration: 0.2)
                                    }
                                    .id("countdown-\(components[1])") // Force animation on number change
                                
                                // Visual phase indicator
                                HStack(spacing: 15) {
                                    makePhaseIndicator(phase: .inhale, currentPhase: viewModel.currentPhase, color: viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    
                                    if let pattern = BreathingPatterns.patterns[viewModel.selectedAnimation], pattern.hold1 > 0 {
                                        makePhaseIndicator(phase: .hold1, currentPhase: viewModel.currentPhase, color: viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    }
                                    
                                    makePhaseIndicator(phase: .exhale, currentPhase: viewModel.currentPhase, color: viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    
                                    if let pattern = BreathingPatterns.patterns[viewModel.selectedAnimation], pattern.hold2 > 0 {
                                        makePhaseIndicator(phase: .hold2, currentPhase: viewModel.currentPhase, color: viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    }
                                }
                                .padding(.top, 10)
                            } else {
                                // Fallback if parsing fails
                                Text(viewModel.countdownText)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                            }
                        }
                        .padding(.top, 100) // Add significant top padding to move it down
                        .padding(.bottom, 30) // Reduced bottom padding
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    // Animation view
                    animationView
                    
                    Spacer()
                    
                    // Bottom controls
                    if showControls {
                        VStack(spacing: 24) {
                            // Play/Pause button
                            Button(action: {
                                if viewModel.isPlaying {
                                    viewModel.pause()
                                } else {
                                    viewModel.play()
                                    showText = true
                                    startInstructionsTimer()
                                }
                                resetControlsTimer()
                            }) {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Time slider
                            VStack(spacing: 10) {
                                HStack {
                                    Text(formatTime(viewModel.elapsedTime))
                                        .font(Typography.Font.caption)
                                        .foregroundColor(ColorPalette.Text.secondary)
                                    
                                    Spacer()
                                    
                                    Text(formatTime(viewModel.totalDuration - viewModel.elapsedTime))
                                        .font(Typography.Font.caption)
                                        .foregroundColor(ColorPalette.Text.secondary)
                                }
                                
                                Slider(value: $viewModel.elapsedTime, in: 0...viewModel.totalDuration, step: 1) { editing in
                                    // Handle slider interaction
                                    if !editing {
                                        // User has finished adjusting slider
                                        viewModel.seekToTime(viewModel.elapsedTime)
                                    }
                                }
                                .accentColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.12))
                                .edgesIgnoringSafeArea(.bottom)
                        )
                        .offset(y: showControls ? 0 : 200)
                        .opacity(showControls ? 1 : 0)
                        .animation(showControls ? .easeInOut : .linear(duration: 0.1), value: showControls)
                    }
                }
                .padding()
            }
        }
        .id("breathingExerciseView-\(shouldStartAfterDismiss ? "active" : "inactive")")
        .fullScreenCover(isPresented: $showCustomizationSheet, onDismiss: {
            // Handle sheet dismissal
            if shouldStartAfterDismiss {
                DispatchQueue.main.async {
                    startBreathingExercise()
                    shouldStartAfterDismiss = false
                }
            }
        }) {
            CustomizationSheetView(viewModel: viewModel, onStart: {
                // Mark that we should start the exercise after sheet dismissal
                shouldStartAfterDismiss = true
            })
        }
        .onAppear {
            enterBreathingMode()
            
            // Add notification observer for exercise completion
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("BreathingExerciseComplete"),
                object: nil,
                queue: .main) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCustomizationSheet = true
                    }
                }
            
            // Show customization sheet immediately when entering the view
            showCustomizationSheet = true
        }
        .onDisappear {
            exitBreathingMode(navigating: false)
            
            // Clear all timers
            instructionsTimer?.invalidate()
            instructionsTimer = nil
            controlsTimer?.invalidate()
            controlsTimer = nil
            
            // Remove notification observer
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BreathingExerciseComplete"), object: nil)
        }
        .onChange(of: viewModel.isPlaying) { oldValue, newValue in
            // Only reset the timer when isPlaying becomes true (don't reset when false)
            if newValue {
                resetControlsTimer()
                // Show instructions when starting to play
                showText = true
                startInstructionsTimer()
            } else {
                // Keep controls visible when paused but don't reset timer
                showControls = true
                // Just invalidate timer without resetting
                if let timer = controlsTimer {
                    timer.invalidate()
                    controlsTimer = nil
                }
            }
        }
        .onChange(of: viewModel.selectedAnimation) { oldValue, newValue in
            // Show instructions when animation type changes
            showText = true
            startInstructionsTimer()
        }
    }
    
    // Start instructions timer to hide instructions after a delay
    private func startInstructionsTimer() {
        // Cancel previous timer if any
        instructionsTimer?.invalidate()
    }
    
    // Handles back button action - separate from exitBreathingMode
    private func handleBackButton() {
        // Notify parent via binding that we want to return to tab view
        tabBarHidden = false
        
        // Reset the exercise state
        viewModel.pause()
        viewModel.elapsedTime = 0
        
        // Use the modern way to get the window for iOS 15+
        if #available(iOS 15.0, *) {
            // Get the active window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.dismiss(animated: true)
            }
        } else {
            // Fallback for older iOS versions
            if let window = UIApplication.shared.windows.first {
                window.rootViewController?.dismiss(animated: true)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("DismissBreathingExercise"), object: nil)
    }
    
    private func startBreathingExercise() {
        tabBarHidden = true
        viewModel.play()
        showText = true
        showControls = true
        resetControlsTimer()
        startInstructionsTimer()
    }
    
    private func enterBreathingMode() {
        // Hide tab bar
        tabBarHidden = true
        
        // Reset controls and animation
        resetControlsTimer()
        showControls = true
        
        // Show instructions
        showText = true
        startInstructionsTimer()
    }
    
    private func exitBreathingMode(navigating: Bool = true) {
        // Show tab bar again
        tabBarHidden = false
        
        // Reset the exercise
        viewModel.pause()
        viewModel.elapsedTime = 0
        
        // Clear timers
        instructionsTimer?.invalidate()
        instructionsTimer = nil
        
        // Navigate back if needed
        if navigating {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func resetControlsTimer() {
        // Cancel any existing hide task
        hideControlsTask?.cancel()
        hideControlsTask = nil
        
        // Only schedule hide if playing
        if viewModel.isPlaying {
            // Create a new task
            let task = DispatchWorkItem {
                // Dispatch back to main thread for UI update
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.showControls = false
                        // Keep the text box for countdown instructions
                        // Only hide the detailed instructions
                        self.showText = false
                    }
                }
            }
            
            // Store the task
            hideControlsTask = task
            
            // Schedule the task after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: task)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Animation view
    private var animationView: some View {
        ZStack {
            // Main animation
            BreathingAnimationView(
                animationType: viewModel.selectedAnimation,
                isPlaying: viewModel.isPlaying,
                isHolding: viewModel.isHolding,
                isBreathingIn: viewModel.isBreathingIn,
                size: viewModel.animationSize,
                scaleFactor: viewModel.scaleFactor
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // Make the whole area tappable
        .onTapGesture {
            // Cancel any pending hide task
            hideControlsTask?.cancel()
            hideControlsTask = nil
            
            // Toggle controls visibility with direct animation
            // This approach doesn't trigger state propagation that could affect the animation
            withAnimation(.easeOut(duration: 0.3)) {
                showControls.toggle()
                if showControls {
                    showText = true
                } else {
                    showText = false
                }
            }
            
            // Reset the auto-hide timer if controls are now visible
            if showControls {
                resetControlsTimer()
            }
        }
    }
    
    // Helper function to create phase indicators
    private func makePhaseIndicator(phase: BreathingPhase, currentPhase: BreathingPhase, color: Color) -> some View {
        Circle()
            .fill(phase == currentPhase ? color : Color.gray.opacity(0.3))
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: phase == currentPhase ? 2 : 0)
                    .scaleEffect(phase == currentPhase ? 1.4 : 1.0)
            )
    }
}

// Add SafeAreaInsets environment key for older iOS versions
private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

// Preview
#Preview {
    BreathingExerciseView()
}
