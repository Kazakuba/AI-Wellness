import SwiftUI

// MARK: - Square Animation
struct SquareAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.8),
                            Color.blue.opacity(0.4),
                            Color.blue.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.2
                    )
                )
                .scaleEffect(scaleFactor * 1.1)
                .opacity(opacity * 0.6)
                .blur(radius: 10)
            
            // Main square gradient
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.9),
                            Color.cyan.opacity(0.7),
                            Color.blue.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.cyan.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.02)
                        .opacity(opacity)
                )
                .shadow(color: Color.blue.opacity(0.5), radius: 15, x: 0, y: 0)
            
            // Corner accents
            ForEach(0..<4) { corner in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .offset(
                        x: corner % 2 == 0 ? -size/3 : size/3,
                        y: corner < 2 ? -size/3 : size/3
                    )
                    .scaleEffect(scaleFactor * 0.8)
                    .opacity(opacity * 0.7)
            }
        }
    }
}

// MARK: - Circle Animation
struct CircleAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.6),
                            Color.pink.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .scaleEffect(scaleFactor * 1.3)
                .opacity(opacity * 0.5)
                .blur(radius: 5)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.9),
                            Color.pink.opacity(0.7),
                            Color.purple.opacity(0.4)
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
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.pink.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color.purple.opacity(0.6), radius: 20, x: 0, y: 0)
            
            // Inner circle pulse
            Circle()
                .fill(Color.white.opacity(0.2))
                .scaleEffect(scaleFactor * 0.6)
                .opacity(opacity * 0.8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .scaleEffect(scaleFactor * 0.6)
                )
        }
    }
}

// MARK: - Triangle Animation
struct TriangleAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    
    var body: some View {
        ZStack {
            TriangleShape()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.6),
                            Color.green.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.2
                    )
                )
                .scaleEffect(scaleFactor * 1.2)
                .rotationEffect(Angle(degrees: rotation))
                .opacity(opacity * 0.4)
                .blur(radius: 8)
            
            TriangleShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.9),
                            Color.mint.opacity(0.7),
                            Color.green.opacity(0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(scaleFactor)
                .rotationEffect(Angle(degrees: rotation))
                .opacity(opacity)
                .overlay(
                    TriangleShape()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.mint.opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.02)
                        .rotationEffect(Angle(degrees: rotation))
                        .opacity(opacity)
                )
                .shadow(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 0)
            
            ForEach(0..<3) { corner in
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: cos(Double(corner) * 2 * .pi / 3) * size/3,
                        y: sin(Double(corner) * 2 * .pi / 3) * size/3
                    )
                    .scaleEffect(scaleFactor * 0.8)
                    .rotationEffect(Angle(degrees: rotation))
                    .opacity(opacity * 0.8)
            }
        }
    }
}

// MARK: - Calm Animation
struct CalmAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: size/2
                        )
                    )
                    .frame(width: size/2, height: size/2)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * (size/3) * scaleFactor,
                        y: sin(Double(index) * .pi / 4) * (size/3) * scaleFactor
                    )
                    .scaleEffect(scaleFactor * 0.9)
                    .opacity(opacity * 0.4)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.8),
                            Color(red: 0.4, green: 0.7, blue: 0.9).opacity(0.6),
                            Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.3)
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
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.7),
                                    Color(red: 0.4, green: 0.7, blue: 0.9).opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.4), radius: 20, x: 0, y: 0)
            
            ForEach(0..<6) { index in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(Double(index) * .pi / 3) * (size/2.5) * scaleFactor,
                        y: sin(Double(index) * .pi / 3) * (size/2.5) * scaleFactor
                    )
                    .scaleEffect(scaleFactor * 0.7)
                    .opacity(opacity * 0.6)
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
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.4),
                            Color.yellow.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/1.2
                    )
                )
                .scaleEffect(scaleFactor * 1.4)
                .opacity(opacity * 0.5)
                .blur(radius: 10)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.95),
                            Color.yellow.opacity(0.8),
                            Color.orange.opacity(0.6)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/2
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.9),
                                    Color.yellow.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color.orange.opacity(0.6), radius: 25, x: 0, y: 0)
            
            // Dynamic rays
            ForEach(0..<12) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.8),
                                Color.yellow.opacity(0.6),
                                Color.orange.opacity(0.3)
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 6, height: size/2.5 * scaleFactor)
                    .offset(y: -size/5 * scaleFactor)
                    .rotationEffect(Angle(degrees: Double(index) * 30 + rotation))
                    .opacity(opacity * 0.7)
            }
            
            Circle()
                .fill(Color.white.opacity(0.4))
                .scaleEffect(scaleFactor * 0.4)
                .opacity(opacity * 0.9)
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
            ForEach(0..<8) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: size/2
                        )
                    )
                    .frame(width: size/3, height: size/3)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * (size/2.5) * scaleFactor,
                        y: sin(Double(index) * .pi / 4) * (size/2.5) * scaleFactor
                    )
                    .scaleEffect(scaleFactor * 0.8)
                    .opacity(opacity * 0.3)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.9),
                            Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.7),
                            Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.4)
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
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color(red: 0.6, green: 0.1, blue: 0.3).opacity(0.5), radius: 20, x: 0, y: 0)
            
            ForEach(0..<6) { index in
                EnhancedNeuralConnectionPath(
                    index: index, 
                    size: size, 
                    scale: scaleFactor, 
                    rotation: rotation, 
                    opacity: opacity, 
                    isBreathingIn: isBreathingIn
                )
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/4
                    )
                )
                .scaleEffect(scaleFactor * 0.4)
                .scaleEffect(isBreathingIn ? 1.2 : 0.8)
                .opacity(opacity * 0.9)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .scaleEffect(scaleFactor * 0.4)
                        .scaleEffect(isBreathingIn ? 1.2 : 0.8)
                )
        }
    }
}

// MARK: - Wave Animation
struct WaveAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<6) { index in
                WaveShape(frequency: 3, amplitude: 0.1, phase: Double(index) * .pi / 3)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.teal.opacity(0.3 * opacity),
                                Color.blue.opacity(0.2 * opacity),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 1.5, height: size * 1.5)
                    .scaleEffect(scaleFactor * (1.0 + Double(index) * 0.1))
                    .rotationEffect(Angle(degrees: rotation * 0.5))
                    .opacity(opacity * (0.8 - Double(index) * 0.1))
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.teal.opacity(0.9),
                            Color.blue.opacity(0.7),
                            Color.teal.opacity(0.4)
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
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.cyan.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color.teal.opacity(0.5), radius: 20, x: 0, y: 0)
            
            ForEach(0..<8) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.cyan.opacity(0.2)
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 8
                        )
                    )
                    .frame(width: 12, height: 12)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * (size/2.2) * scaleFactor,
                        y: sin(Double(index) * .pi / 4) * (size/2.2) * scaleFactor
                    )
                    .scaleEffect(scaleFactor * 0.6)
                    .opacity(opacity * 0.7)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.5),
                            Color.cyan.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/3
                    )
                )
                .scaleEffect(scaleFactor * 0.5)
                .scaleEffect(isBreathingIn ? 1.3 : 0.9)
                .opacity(opacity * 0.8)
        }
    }
}

// MARK: - Spiral Animation
struct SpiralAnimationView: View {
    let scaleFactor: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<4) { index in
                SpiralShape(turns: 2, startRadius: 10, endRadius: size/2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.4 * opacity),
                                Color.purple.opacity(0.2 * opacity),
                                Color.clear
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(scaleFactor * (1.0 + Double(index) * 0.2))
                    .rotationEffect(Angle(degrees: rotation + Double(index) * 45))
                    .opacity(opacity * (0.6 - Double(index) * 0.1))
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.indigo.opacity(0.9),
                            Color.purple.opacity(0.7),
                            Color.indigo.opacity(0.4)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/2
                    )
                )
                .scaleEffect(scaleFactor)
                .opacity(opacity)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.purple.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .scaleEffect(scaleFactor * 1.05)
                        .opacity(opacity)
                )
                .shadow(color: Color.indigo.opacity(0.6), radius: 25, x: 0, y: 0)
            
            ForEach(0..<12) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.purple.opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 6
                        )
                    )
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(Double(index) * .pi / 6) * (size/2.8) * scaleFactor,
                        y: sin(Double(index) * .pi / 6) * (size/2.8) * scaleFactor
                    )
                    .scaleEffect(scaleFactor * 0.5)
                    .rotationEffect(Angle(degrees: rotation * 2))
                    .opacity(opacity * 0.8)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color.purple.opacity(0.4)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/4
                    )
                )
                .scaleEffect(scaleFactor * 0.4)
                .scaleEffect(isBreathingIn ? 1.4 : 0.8)
                .opacity(opacity * 0.9)
        }
    }
}
