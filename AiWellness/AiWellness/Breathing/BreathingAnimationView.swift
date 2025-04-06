//
//  BreathingAnimationView.swift
//  AiWellness
//
//  Created by Kazakuba on 05.04.25.
//

import SwiftUI

struct BreathingAnimationView: View {
    let animationType: String
    let isPlaying: Bool
    let isHolding: Bool
    let isBreathingIn: Bool
    let size: CGFloat
    let scaleFactor: CGFloat
    
    // State for rotation (only needed for some animations)
    @State private var rotation: Double = 0
    
    // Rotation timer
    @State private var rotationTimer: Timer? = nil
    
    var body: some View {
        ZStack {
            // The animation view changes based on the selected type
            Group {
                switch animationType {
                case "Square":
                    SquareAnimationView(scaleFactor: scaleFactor, size: size, opacity: calculateOpacity())
                case "Circle":
                    CircleAnimationView(scaleFactor: scaleFactor, size: size, opacity: calculateOpacity())
                case "Triangle":
                    TriangleAnimationView(scaleFactor: scaleFactor, size: size, rotation: rotation, opacity: calculateOpacity())
                case "Calm":
                    CalmAnimationView(scaleFactor: scaleFactor, size: size, opacity: calculateOpacity())
                case "Energy":
                    EnergyAnimationView(scaleFactor: scaleFactor, size: size, rotation: rotation, opacity: calculateOpacity())
                case "Focus":
                    FocusAnimationView(
                        scaleFactor: scaleFactor, 
                        size: size, 
                        rotation: rotation, 
                        opacity: calculateOpacity(),
                        isBreathingIn: isBreathingIn
                    )
                default:
                    CircleAnimationView(scaleFactor: scaleFactor, size: size, opacity: calculateOpacity())
                }
            }
            .frame(width: size, height: size)
            .onAppear {
                print("DEBUG: Animation - onAppear")
                resetAnimation()
                if isPlaying {
                    startRotationIfNeeded()
                }
            }
            .onChange(of: isPlaying) { oldValue, newValue in
                if newValue {
                    startRotationIfNeeded()
                } else {
                    stopRotation()
                }
            }
            .onChange(of: isHolding) { oldValue, newValue in
                // When holding changes, we may need to pause/resume rotation
                updateRotationForHoldingState()
            }
            .onChange(of: animationType) { oldValue, newValue in
                resetAnimation()
                if isPlaying {
                    startRotationIfNeeded()
                }
            }
        }
    }
    
    // Calculate opacity based on scale factor (more opaque when expanded)
    private func calculateOpacity() -> Double {
        let minScale: CGFloat = 0.8
        let maxScale: CGFloat = 1.2
        return 0.7 + 0.3 * ((scaleFactor - minScale) / (maxScale - minScale))
    }
    
    // Reset animation to initial state
    private func resetAnimation() {
        // Stop any existing rotation timers
        stopRotation()
        
        // Reset rotation value
        rotation = 0
    }
    
    // Start rotation timer if animation type needs it
    private func startRotationIfNeeded() {
        if ["Triangle", "Energy", "Focus"].contains(animationType) {
            rotationTimer?.invalidate()
            
            rotationTimer = Timer(timeInterval: 0.05, repeats: true) { _ in
                // Only rotate when not in a holding phase
                if !isHolding {
                    DispatchQueue.main.async {
                        withAnimation(.linear(duration: 0.05)) {
                            self.rotation = (self.rotation + 0.5).truncatingRemainder(dividingBy: 360)
                        }
                    }
                }
            }
            
            // Add to RunLoop for better control
            RunLoop.main.add(rotationTimer!, forMode: .common)
        }
    }
    
    // Update rotation behavior when holding state changes
    private func updateRotationForHoldingState() {
        if isPlaying && ["Triangle", "Energy", "Focus"].contains(animationType) {
            if isHolding {
                // When holding, we can keep the rotation timer but it won't increment
            } else if rotationTimer == nil {
                // If timer got invalidated, restart it
                startRotationIfNeeded()
            }
        }
    }
    
    // Stop rotation timer
    private func stopRotation() {        
        // Invalidate rotation timer
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
}

// Preview
struct BreathingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Breathing Animations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                BreathingAnimationView(
                    animationType: "Circle",
                    isPlaying: true,
                    isHolding: false,
                    isBreathingIn: true,
                    size: 150,
                    scaleFactor: 1.0
                )
                
                BreathingAnimationView(
                    animationType: "Square",
                    isPlaying: true,
                    isHolding: true,
                    isBreathingIn: true,
                    size: 150,
                    scaleFactor: 1.0
                )
                
                BreathingAnimationView(
                    animationType: "Energy",
                    isPlaying: true,
                    isHolding: false,
                    isBreathingIn: true,
                    size: 150,
                    scaleFactor: 1.0
                )
            }
        }
    }
} 
