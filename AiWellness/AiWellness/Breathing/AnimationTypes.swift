import SwiftUI

// MARK: - Square Animation
struct SquareAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.blue.opacity(0.3)
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: size/1.5
                )
            )
            .scaleEffect(scaleFactor)
            .opacity(opacity)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .scaleEffect(scaleFactor * 1.05)
                    .opacity(opacity)
            )
    }
}

// MARK: - Circle Animation
struct CircleAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.7),
                        Color.purple.opacity(0.3)
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: size/1.5
                )
            )
            .scaleEffect(scaleFactor)
            .opacity(opacity)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .scaleEffect(scaleFactor * 1.05)
                    .opacity(opacity)
            )
    }
}

// MARK: - Triangle Animation
struct TriangleAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    
    var body: some View {
        TriangleShape()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.7),
                        Color.green.opacity(0.3)
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: size/1.5
                )
            )
            .scaleEffect(scaleFactor)
            .rotationEffect(Angle(degrees: rotation))
            .opacity(opacity)
            .overlay(
                TriangleShape()
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .scaleEffect(scaleFactor * 1.05)
                    .rotationEffect(Angle(degrees: rotation))
                    .opacity(opacity)
            )
    }
}

// MARK: - Calm Animation
struct CalmAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.7),
                            Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.5
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
            
            // Multiple overlapping circles for cloud effect
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: size/3, height: size/3)
                    .offset(
                        x: cos(Double(index) * .pi * 2/5) * (size/3) * scaleFactor,
                        y: sin(Double(index) * .pi * 2/5) * (size/3) * scaleFactor
                    )
                    .scaleEffect(scaleFactor)
                    .opacity(opacity * 0.7)
            }
        }
    }
}

// MARK: - Energy Animation
struct EnergyAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Central sun-like circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.9),
                            Color.orange.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.5
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
            
            // Rays - rotate only when not holding
            ForEach(0..<8) { index in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 10, height: size/2 * scaleFactor)
                    .offset(y: -size/4 * scaleFactor)
                    .rotationEffect(Angle(degrees: Double(index) * 45 + rotation))
            }
        }
    }
}

// MARK: - Focus Animation
struct FocusAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            // Core circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.8),
                            Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.5
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
            
            // Neural connections
            ForEach(0..<6) { index in
                NeuralConnectionPath(
                    index: index, 
                    size: size, 
                    scale: scaleFactor, 
                    rotation: rotation, 
                    opacity: opacity, 
                    isBreathingIn: isBreathingIn
                )
            }
            
            // Smaller inner circle representing focus - scale based on breathing in/out
            Circle()
                .fill(Color.white.opacity(0.3))
                .scaleEffect(scaleFactor * 0.4)
                .scaleEffect(isBreathingIn ? 1.1 : 0.9)
        }
    }
}
