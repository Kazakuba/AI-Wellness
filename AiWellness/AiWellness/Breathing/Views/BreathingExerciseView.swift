//
//  BreathingExerciseView.swift
//  AiWellness
//
//  Created by Kazakuba on 05.04.25.
//

import SwiftUI
import ConfettiSwiftUI

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
    @Binding var tabBarHidden: Bool
    @State private var hideControlsTask: DispatchWorkItem? = nil
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @StateObject private var confettiManager = ConfettiManager.shared

    init(tabBarHidden: Binding<Bool> = .constant(false)) {
        self._tabBarHidden = tabBarHidden
    }
    
    var body: some View {
        ZStack {
            (isDarkMode ?
                LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.75),
                        Color(red: 1.0, green: 0.72, blue: 0.58)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .edgesIgnoringSafeArea(.all)

            
            if showCustomizationSheet {
                ColorPalette.background.edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 0) {
                    if showControls {
                        HStack {
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
                        }
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: showControls)
                    }
                    
                    Spacer().frame(height: 20)
                    
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
                        VStack(spacing: 8) {
                            let components = viewModel.countdownText.components(separatedBy: " ")
                            if components.count == 2 {
                                Text(components[0])
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    .padding(.bottom, 5)
                                
                                Text(components[1])
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                                    .contentTransition(.numericText())
                                    .transaction { transaction in
                                        transaction.animation = .easeInOut(duration: 0.2)
                                    }
                                    .id("countdown-\(components[1])")
                                
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
                                Text(viewModel.countdownText)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(viewModel.getColorForType(type: viewModel.selectedAnimation))
                            }
                        }
                        .padding(.top, 100)
                        .padding(.bottom, 30)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    animationView
                    
                    Spacer()
                    
                    if showControls {
                        VStack(spacing: 24) {
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
                                    if !editing {
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
            if shouldStartAfterDismiss {
                DispatchQueue.main.async {
                    startBreathingExercise()
                    shouldStartAfterDismiss = false
                }
            }
        }) {
            CustomizationSheetView(viewModel: viewModel, onStart: {
                shouldStartAfterDismiss = true
            })
        }
        .onAppear {
            enterBreathingMode()
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("BreathingExerciseComplete"),
                object: nil,
                queue: .main) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCustomizationSheet = true
                    }
                }
            
            showCustomizationSheet = true
        }
        .onDisappear {
            exitBreathingMode(navigating: false)
            
            instructionsTimer?.invalidate()
            instructionsTimer = nil
            controlsTimer?.invalidate()
            controlsTimer = nil
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BreathingExerciseComplete"), object: nil)
        }
        .onChange(of: viewModel.isPlaying) { oldValue, newValue in
            if newValue {
                resetControlsTimer()
                showText = true
                startInstructionsTimer()
            } else {
                showControls = true
                if let timer = controlsTimer {
                    timer.invalidate()
                    controlsTimer = nil
                }
            }
        }
        .onChange(of: viewModel.selectedAnimation) { oldValue, newValue in
            showText = true
            startInstructionsTimer()
        }
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, confettis: confettiManager.confettis, colors: [.yellow, .green, .blue, .orange])
    }
    
    private func startInstructionsTimer() {
        instructionsTimer?.invalidate()
    }
    
    private func handleBackButton() {
        showCustomizationSheet = true
        viewModel.pause()
        viewModel.elapsedTime = 0
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
        tabBarHidden = true
        
        resetControlsTimer()
        showControls = true
        
        showText = true
        startInstructionsTimer()
    }
    
    private func exitBreathingMode(navigating: Bool = true) {
        tabBarHidden = false
        
        viewModel.pause()
        viewModel.elapsedTime = 0
        
        instructionsTimer?.invalidate()
        instructionsTimer = nil
        
        if navigating {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func resetControlsTimer() {
        hideControlsTask?.cancel()
        hideControlsTask = nil
        
        if viewModel.isPlaying {
            let task = DispatchWorkItem {
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.showControls = false
                        self.showText = false
                    }
                }
            }
            
            hideControlsTask = task
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: task)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var animationView: some View {
        ZStack {
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
        .contentShape(Rectangle())
        .onTapGesture {
            hideControlsTask?.cancel()
            hideControlsTask = nil
            withAnimation(.easeOut(duration: 0.3)) {
                showControls.toggle()
                if showControls {
                    showText = true
                } else {
                    showText = false
                }
            }
            if showControls {
                resetControlsTimer()
            }
        }
    }
    
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

#Preview {
    BreathingExerciseView()
}
