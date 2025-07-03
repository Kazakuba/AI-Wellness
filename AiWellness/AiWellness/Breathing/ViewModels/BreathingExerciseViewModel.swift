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
    @Published var selectedAnimation: String = "Square"
    @Published var animationSize: CGFloat = 200
    @Published var animationTypes: [String] = ThemeCategories.allThemes
    
    @Published var scaleFactor: CGFloat = 0.8
    
    private let minScale: CGFloat = 0.8
    private let maxScale: CGFloat = 1.2
    
    @Published var isPlaying: Bool = false
    @Published var isBreathingIn: Bool = true
    @Published var isHolding: Bool = false
    @Published var elapsedTime: Double = 0
    @Published var totalDuration: Double = 180
    @Published var currentInstructions: String = ""
    @Published var countdownText: String = ""
    @Published var currentPhase: BreathingPhase = .inhale
    
    private var timer: Timer?
    private var phaseTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private var phaseStartTime: Date?
    private var currentPhaseElapsed: Double = 0
    private var showingFullInstructions: Bool = true
    
    init() {
        currentInstructions = BreathingInstructions.getInstructions(for: selectedAnimation)
        
        $elapsedTime
            .sink { [weak self] time in
                guard let self = self else { return }
                if self.isPlaying {
                    if time >= self.totalDuration {
                        self.pause()
                        self.elapsedTime = 0
                        
                        let uid = GamificationManager.shared.getUserUID() ?? "default"
                        let breathKey = "first_breath_\(uid)"
                        let defaults = UserDefaults.standard
                        let hasBreathBefore = defaults.bool(forKey: breathKey)
                        if !hasBreathBefore {
                            defaults.set(true, forKey: breathKey)
                            if GamificationManager.shared.incrementAchievement("first_breath") {
                                ConfettiManager.shared.celebrate()
                            }
                            GamificationManager.shared.save()
                        }
                        
                        let breathworkProKey = "breathwork_pro_sessions_\(uid)"
                        var completedSessions = defaults.integer(forKey: breathworkProKey)
                        completedSessions += 1
                        defaults.set(completedSessions, forKey: breathworkProKey)
                        if GamificationManager.shared.incrementBadge("breathwork_pro") {
                            ConfettiManager.shared.celebrate()
                        }
                        GamificationManager.shared.save()
                        
                        ConfettiManager.shared.celebrate()
                    }
                }
            }
            .store(in: &cancellables)
            
        $selectedAnimation
            .sink { [weak self] animation in
                guard let self = self else { return }
                self.currentInstructions = BreathingInstructions.getInstructions(for: animation)
                self.showingFullInstructions = true
                self.resetExercise()
            }
            .store(in: &cancellables)
            
        $totalDuration
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.resetExercise()
            }
            .store(in: &cancellables)
    }
    
    func getThemesForCategory(_ category: String) -> [String] {
        return ThemeCategories.getThemesForCategory(category)
    }
    
    func getPhaseInstruction() -> String {
        return BreathingInstructions.getPhaseInstruction(for: currentPhase)
    }
    
    func play() {
        isPlaying = true
        
        timer?.invalidate()
        phaseTimer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
        }
        
        startBreathingPhaseTimer()
    }
    
    func pause() {
        isPlaying = false
        timer?.invalidate()
        phaseTimer?.invalidate()
        timer = nil
        phaseTimer = nil
    }
    
    func resetExercise() {
        pause()
        elapsedTime = 0
        currentPhase = .inhale
        isBreathingIn = true
        isHolding = false
        currentPhaseElapsed = 0
        scaleFactor = minScale
        
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        countdownText = "Inhale \(Int(pattern.inhale))"
    }
    
    func seekToTime(_ time: Double) {
        elapsedTime = time
        
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        
        let cycleDuration = pattern.inhale + pattern.hold1 + pattern.exhale + pattern.hold2
        
        guard cycleDuration > 0 else { return }
        
        let completedCycles = Int(time / cycleDuration)
        
        let timeInCurrentCycle = time - Double(completedCycles) * cycleDuration
        
        var elapsedInPhase: Double = 0
        
        if timeInCurrentCycle < pattern.inhale {
            currentPhase = .inhale
            elapsedInPhase = timeInCurrentCycle
            isBreathingIn = true
            isHolding = false
        } else if timeInCurrentCycle < pattern.inhale + pattern.hold1 {
            currentPhase = .hold1
            elapsedInPhase = timeInCurrentCycle - pattern.inhale
            isBreathingIn = true
            isHolding = true
        } else if timeInCurrentCycle < pattern.inhale + pattern.hold1 + pattern.exhale {
            currentPhase = .exhale
            elapsedInPhase = timeInCurrentCycle - (pattern.inhale + pattern.hold1)
            isBreathingIn = false
            isHolding = false
        } else {
            currentPhase = .hold2
            elapsedInPhase = timeInCurrentCycle - (pattern.inhale + pattern.hold1 + pattern.exhale)
            isBreathingIn = false
            isHolding = true
        }
        
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
        
        if phaseDuration > 0 {
            updateScaleFactor(elapsed: elapsedInPhase, duration: phaseDuration)
            
            currentPhaseElapsed = elapsedInPhase
            phaseStartTime = Date().addingTimeInterval(-elapsedInPhase)
            
            if isPlaying {
                phaseTimer?.invalidate()
                startBreathingPhaseTimer()
            }
        }
    }
    
    private func startBreathingPhaseTimer() {
        currentPhaseElapsed = 0
        phaseStartTime = Date()
        
        if !showingFullInstructions {
            currentInstructions = getPhaseInstruction()
        }
        
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        var phaseDuration: Double
        
        switch currentPhase {
        case .inhale:
            phaseDuration = pattern.inhale
            isBreathingIn = true
            isHolding = false
            scaleFactor = minScale
            countdownText = "Inhale \(Int(pattern.inhale))"
        case .hold1:
            phaseDuration = pattern.hold1
            isBreathingIn = true
            isHolding = true
            scaleFactor = maxScale
            countdownText = "Hold \(Int(pattern.hold1))"
        case .exhale:
            phaseDuration = pattern.exhale
            isBreathingIn = false
            isHolding = false
            scaleFactor = maxScale
            countdownText = "Exhale \(Int(pattern.exhale))"
        case .hold2:
            phaseDuration = pattern.hold2
            isBreathingIn = false
            isHolding = true
            scaleFactor = minScale
            countdownText = "Hold \(Int(pattern.hold2))"
        }
        
        if phaseDuration <= 0 {
            moveToNextPhase()
            return
        }
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.phaseStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            self.currentPhaseElapsed = elapsed
            
            self.updateScaleFactor(elapsed: elapsed, duration: phaseDuration)
            
            if self.showingFullInstructions && elapsed > 10 {
                self.showingFullInstructions = false
                self.currentInstructions = self.getPhaseInstruction()
            }
            
            if elapsed >= phaseDuration {
                self.moveToNextPhase()
            }
        }
    }
    
    private func updateScaleFactor(elapsed: Double, duration: Double) {
        guard duration > 0 else { return }
        
        let progress = min(1.0, elapsed / duration)
        
        let remainingSeconds = Int(ceil(duration - elapsed))
        
        switch currentPhase {
        case .inhale:
            countdownText = "Inhale \(remainingSeconds)"
            scaleFactor = minScale + (maxScale - minScale) * CGFloat(progress)
        case .hold1:
            countdownText = "Hold \(remainingSeconds)"
            scaleFactor = maxScale
        case .exhale:
            countdownText = "Exhale \(remainingSeconds)"
            scaleFactor = maxScale - (maxScale - minScale) * CGFloat(progress)
        case .hold2:
            countdownText = "Hold \(remainingSeconds)"
            scaleFactor = minScale
        }
    }
    
    private func moveToNextPhase() {
        phaseTimer?.invalidate()
        
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
        
        let pattern = BreathingPatterns.getPattern(for: selectedAnimation)
        var phaseDuration: Double = 0
        
        switch currentPhase {
        case .inhale:
            phaseDuration = pattern.inhale
            isBreathingIn = true
            if isHolding != false {
                isHolding = false
            }
            countdownText = "Inhale \(Int(pattern.inhale))"
        case .hold1:
            phaseDuration = pattern.hold1
            isBreathingIn = true
            if isHolding != true && phaseDuration > 0 {
                isHolding = true
            }
            countdownText = "Hold \(Int(pattern.hold1))"
        case .exhale:
            phaseDuration = pattern.exhale
            isBreathingIn = false
            if isHolding != false {
                isHolding = false
            }
            countdownText = "Exhale \(Int(pattern.exhale))"
        case .hold2:
            phaseDuration = pattern.hold2
            isBreathingIn = false
            if isHolding != true && phaseDuration > 0 {
                isHolding = true
            }
            countdownText = "Hold \(Int(pattern.hold2))"
        }
        
        if isPlaying {
            startBreathingPhaseTimer()
        }
    }
    
    func setAnimationForType(_ type: String) {
        selectedAnimation = type
    }
    
    func setDuration(_ duration: Double) {
        totalDuration = duration
    }
    
    func getAnimationIconName(for type: String) -> String {
        return AnimationVisuals.getIconName(for: type)
    }
    
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
