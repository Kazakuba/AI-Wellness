//
//  BreathingExerciseViewModel.swift
//  AiWellness
//
//  Created by Kazakuba on 05.04.25.
//

import Foundation
import SwiftUI
import Combine

class BreathingExerciseViewModel: ObservableObject {
    // Animation configuration
    @Published var selectedAnimation: String = "Square" // Default animation
    @Published var animationSize: CGFloat = 200 // Default size
    @Published var animationTypes: [String] = ThemeCategories.allThemes
    
    // Scale factor for animations - will be updated continuously
    @Published var scaleFactor: CGFloat = 0.8
    
    // Constants for animation scaling
    private let minScale: CGFloat = 0.8
    private let maxScale: CGFloat = 1.2
    
    // Exercise state
    @Published var isPlaying: Bool = false
    @Published var isBreathingIn: Bool = true
    @Published var isHolding: Bool = false
    @Published var elapsedTime: Double = 0
    @Published var totalDuration: Double = 180 // Default: 3 minutes
    
    // Current instructions for display
    @Published var currentInstructions: String = ""
    
    // Countdown guide text
    @Published var countdownText: String = ""
    
    // Current breathing phase
    @Published var currentPhase: BreathingPhase = .inhale
    
    // Timer
    private var timer: Timer?
    private var phaseTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Current phase info
    private var phaseStartTime: Date?
    private var currentPhaseElapsed: Double = 0
    private var showingFullInstructions: Bool = true
    
    init() {
        currentInstructions = BreathingInstructions.getInstructions(for: selectedAnimation)
        
        // Monitor elapsed time
        $elapsedTime
            .sink { [weak self] time in
                guard let self = self else { return }
                if self.isPlaying {
                    // Check if we reached the end of the exercise
                    if time >= self.totalDuration {
                        self.pause()
                        self.elapsedTime = 0
                        
                        // --- First Breath achievement logic ---
                        let uid = GamificationManager.shared.getUserUID() ?? "default"
                        let breathKey = "first_breath_\(uid)"
                        let defaults = UserDefaults.standard
                        let hasBreathBefore = defaults.bool(forKey: breathKey)
                        if !hasBreathBefore {
                            defaults.set(true, forKey: breathKey)
                            // Unlock "First Breath" achievement
                            if GamificationManager.shared.incrementAchievement("first_breath") {
                                ConfettiManager.shared.celebrate()
                            }
                            GamificationManager.shared.save()
                        }
                        
                        // --- Breathwork Pro badge logic ---
                        let breathworkProKey = "breathwork_pro_sessions_\(uid)"
                        var completedSessions = defaults.integer(forKey: breathworkProKey)
                        completedSessions += 1
                        defaults.set(completedSessions, forKey: breathworkProKey)
                        // Update Breathwork Pro badge progress
                        if GamificationManager.shared.incrementBadge("breathwork_pro") {
                            ConfettiManager.shared.celebrate()
                        }
                        GamificationManager.shared.save()
                        
                        // Notify that the exercise is complete
                        ConfettiManager.shared.celebrate()
                    }
                }
            }
            .store(in: &cancellables)
            
        // Monitor changes to selected animation
        $selectedAnimation
            .sink { [weak self] animation in
                guard let self = self else { return }
                self.currentInstructions = BreathingInstructions.getInstructions(for: animation)
                self.showingFullInstructions = true
                self.resetExercise()
            }
            .store(in: &cancellables)
            
        // Monitor changes to duration
        $totalDuration
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.resetExercise()
            }
            .store(in: &cancellables)
    }
    
    // Get themes for a specific category
    func getThemesForCategory(_ category: String) -> [String] {
        return ThemeCategories.getThemesForCategory(category)
    }
    
    // Get current breathing instruction based on the phase
    func getPhaseInstruction() -> String {
        return BreathingInstructions.getPhaseInstruction(for: currentPhase)
    }
    
    // Start playing
    func play() {
        isPlaying = true
        
        // Cancel existing timers if any
        timer?.invalidate()
        phaseTimer?.invalidate()
        
        // Start main timer to update elapsed time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
        }
        
        // Start breathing phase timer
        startBreathingPhaseTimer()
    }
    
    // Pause playing
    func pause() {
        isPlaying = false
        timer?.invalidate()
        phaseTimer?.invalidate()
        timer = nil
        phaseTimer = nil
    }
    
    // Reset exercise completely
    func resetExercise() {
        pause()
        elapsedTime = 0
        currentPhase = .inhale
        isBreathingIn = true
        isHolding = false
        currentPhaseElapsed = 0
        scaleFactor = minScale
        
        // Reset the countdown text
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        countdownText = "Inhale \(Int(pattern.inhale))"
    }
    
    // Seek to specific time
    func seekToTime(_ time: Double) {
        elapsedTime = time
        
        // Calculate which phase we should be in at this time point
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        
        // Calculate full cycle duration
        let cycleDuration = pattern.inhale + pattern.hold1 + pattern.exhale + pattern.hold2
        
        // If cycle duration is 0, can't do anything
        guard cycleDuration > 0 else { return }
        
        // Calculate completed cycles
        let completedCycles = Int(time / cycleDuration)
        
        // Calculate time within current cycle
        let timeInCurrentCycle = time - Double(completedCycles) * cycleDuration
        
        // Determine the current phase and elapsed time within that phase
        var elapsedInPhase: Double = 0
        
        if timeInCurrentCycle < pattern.inhale {
            // Inhale phase
            currentPhase = .inhale
            elapsedInPhase = timeInCurrentCycle
            isBreathingIn = true
            isHolding = false
        } else if timeInCurrentCycle < pattern.inhale + pattern.hold1 {
            // Hold1 phase
            currentPhase = .hold1
            elapsedInPhase = timeInCurrentCycle - pattern.inhale
            isBreathingIn = true
            isHolding = true
        } else if timeInCurrentCycle < pattern.inhale + pattern.hold1 + pattern.exhale {
            // Exhale phase
            currentPhase = .exhale
            elapsedInPhase = timeInCurrentCycle - (pattern.inhale + pattern.hold1)
            isBreathingIn = false
            isHolding = false
        } else {
            // Hold2 phase
            currentPhase = .hold2
            elapsedInPhase = timeInCurrentCycle - (pattern.inhale + pattern.hold1 + pattern.exhale)
            isBreathingIn = false
            isHolding = true
        }
        
        // Get duration for the current phase
        var phaseDuration: Double = 0
        switch currentPhase {
        case .inhale:
            phaseDuration = pattern.inhale
        case .hold1:
            phaseDuration = pattern.hold1
        case .exhale:
            phaseDuration = pattern.exhale
        case .hold2:
            phaseDuration = pattern.hold2
        }
        
        // Update scale factor and countdown text
        if phaseDuration > 0 {
            updateScaleFactor(elapsed: elapsedInPhase, duration: phaseDuration)
            
            // Store current phase info for animation continuity
            currentPhaseElapsed = elapsedInPhase
            phaseStartTime = Date().addingTimeInterval(-elapsedInPhase)
            
            // If timers are running, stop them and restart
            if isPlaying {
                phaseTimer?.invalidate()
                startBreathingPhaseTimer()
            }
        }
    }
    
    // Start the breathing phase timer
    private func startBreathingPhaseTimer() {
        currentPhaseElapsed = 0
        phaseStartTime = Date()
        
        // Update the instruction text
        if !showingFullInstructions {
            currentInstructions = getPhaseInstruction()
        }
        
        // Get the duration for the current phase
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        var phaseDuration: Double
        
        switch currentPhase {
        case .inhale:
            phaseDuration = pattern.inhale
            isBreathingIn = true
            isHolding = false
            // Start with min scale for inhale
            scaleFactor = minScale
            // Initialize countdown text
            countdownText = "Inhale \(Int(pattern.inhale))"
        case .hold1:
            phaseDuration = pattern.hold1
            isBreathingIn = true
            isHolding = true
            // Hold at max scale
            scaleFactor = maxScale
            // Initialize countdown text
            countdownText = "Hold \(Int(pattern.hold1))"
        case .exhale:
            phaseDuration = pattern.exhale
            isBreathingIn = false
            isHolding = false
            // Start with max scale for exhale
            scaleFactor = maxScale
            // Initialize countdown text
            countdownText = "Exhale \(Int(pattern.exhale))"
        case .hold2:
            phaseDuration = pattern.hold2
            isBreathingIn = false
            isHolding = true
            // Hold at min scale
            scaleFactor = minScale
            // Initialize countdown text
            countdownText = "Hold \(Int(pattern.hold2))"
        }
        
        // If phase duration is 0, skip to next phase
        if phaseDuration <= 0 {
            moveToNextPhase()
            return
        }
        
        // Start timer for this phase
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.phaseStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            self.currentPhaseElapsed = elapsed
            
            // Update scale factor based on current phase and elapsed time
            self.updateScaleFactor(elapsed: elapsed, duration: phaseDuration)
            
            // After 10 seconds, switch to showing only phase instructions
            if self.showingFullInstructions && elapsed > 10 {
                self.showingFullInstructions = false
                self.currentInstructions = self.getPhaseInstruction()
            }
            
            // When phase is complete, move to next
            if elapsed >= phaseDuration {
                self.moveToNextPhase()
            }
        }
    }
    
    // Update scale factor based on breathing phase
    private func updateScaleFactor(elapsed: Double, duration: Double) {
        guard duration > 0 else { return }
        
        // Calculate progress as a value between 0 and 1
        let progress = min(1.0, elapsed / duration)
        
        // Calculate remaining time for this phase (rounded up to the nearest integer)
        let remainingSeconds = Int(ceil(duration - elapsed))
        
        // Update countdown text based on the current phase
        switch currentPhase {
        case .inhale:
            countdownText = "Inhale \(remainingSeconds)"
            // Scale grows from minScale to maxScale during inhale
            scaleFactor = minScale + (maxScale - minScale) * CGFloat(progress)
        case .hold1:
            countdownText = "Hold \(remainingSeconds)"
            // Hold at maximum scale
            scaleFactor = maxScale
        case .exhale:
            countdownText = "Exhale \(remainingSeconds)"
            // Scale shrinks from maxScale to minScale during exhale
            scaleFactor = maxScale - (maxScale - minScale) * CGFloat(progress)
        case .hold2:
            countdownText = "Hold \(remainingSeconds)"
            // Hold at minimum scale
            scaleFactor = minScale
        }
    }
    
    // Move to the next breathing phase
    private func moveToNextPhase() {
        phaseTimer?.invalidate()
        
        // Progress to next phase
        switch currentPhase {
        case .inhale:
            currentPhase = .hold1
        case .hold1:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .hold2
        case .hold2:
            currentPhase = .inhale
        }
        
        // Get the duration for the new phase
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        var phaseDuration: Double = 0
        
        switch currentPhase {
        case .inhale:
            phaseDuration = pattern.inhale
            isBreathingIn = true
            if isHolding != false {
                isHolding = false
            }
            // Initialize countdown text for this phase
            countdownText = "Inhale \(Int(pattern.inhale))"
        case .hold1:
            phaseDuration = pattern.hold1
            isBreathingIn = true
            if isHolding != true && phaseDuration > 0 {
                isHolding = true
            }
            // Initialize countdown text for this phase
            countdownText = "Hold \(Int(pattern.hold1))"
        case .exhale:
            phaseDuration = pattern.exhale
            isBreathingIn = false
            if isHolding != false {
                isHolding = false
            }
            // Initialize countdown text for this phase
            countdownText = "Exhale \(Int(pattern.exhale))"
        case .hold2:
            phaseDuration = pattern.hold2
            isBreathingIn = false
            if isHolding != true && phaseDuration > 0 {
                isHolding = true
            }
            // Initialize countdown text for this phase
            countdownText = "Hold \(Int(pattern.hold2))"
        }
        
        // Start timer for the new phase
        if isPlaying {
            startBreathingPhaseTimer()
        }
    }
    
    // Set animation type
    func setAnimationForType(_ type: String) {
        selectedAnimation = type
    }
    
    // Set exercise duration
    func setDuration(_ duration: Double) {
        totalDuration = duration
    }
    
    // Get icon name for animation type
    func getAnimationIconName(for type: String) -> String {
        return AnimationVisuals.getIconName(for: type)
    }
    
    // Get color for animation type
    func getColorForType(type: String) -> Color {
        return AnimationVisuals.getColor(for: type)
    }
    
    deinit {
        timer?.invalidate()
        phaseTimer?.invalidate()
        timer = nil
        phaseTimer = nil
        cancellables.removeAll()
    }
} 
