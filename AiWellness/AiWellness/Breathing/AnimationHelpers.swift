import SwiftUI

// MARK: - Custom Triangle Shape
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    let frequency: Double
    let amplitude: Double
    let phase: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        
        path.move(to: CGPoint(x: 0, y: centerY))
        
        for x in stride(from: 0, through: width, by: 1) {
            let normalizedX = x / width
            let waveY = centerY + sin(normalizedX * frequency * 2 * .pi + phase) * amplitude * height
            path.addLine(to: CGPoint(x: x, y: waveY))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Spiral Shape
struct SpiralShape: Shape {
    let turns: Double
    let startRadius: Double
    let endRadius: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let centerY = rect.midY
        let maxRadius = min(rect.width, rect.height) / 2
        
        let startAngle = 0.0
        let endAngle = turns * 2 * .pi
        let angleStep = 0.1
        
        var firstPoint = true
        
        for angle in stride(from: startAngle, through: endAngle, by: angleStep) {
            let progress = angle / endAngle
            let radius = startRadius + (endRadius - startRadius) * progress
            let scaledRadius = radius * maxRadius / endRadius
            
            let x = centerX + cos(angle) * scaledRadius
            let y = centerY + sin(angle) * scaledRadius
            
            if firstPoint {
                path.move(to: CGPoint(x: x, y: y))
                firstPoint = false
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Enhanced Neural Connection Path
struct EnhancedNeuralConnectionPath: View {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            // Glow effect for the connection
            EnhancedConnectionPath(index: index, size: size, scale: scale, rotation: rotation)
                .stroke(
                    Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.3 * opacity),
                    lineWidth: 8
                )
                .blur(radius: 4)
            
            // Main connection path
            EnhancedConnectionPath(index: index, size: size, scale: scale, rotation: rotation)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.8 * opacity),
                            Color(red: 0.9, green: 0.3, blue: 0.5).opacity(0.6 * opacity),
                            Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.4 * opacity)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
            
            // Enhanced node points
            EnhancedConnectionNode(index: index, size: size, scale: scale, rotation: rotation, opacity: opacity, isBreathingIn: isBreathingIn)
        }
    }
}

// MARK: - Enhanced Connection Path
struct EnhancedConnectionPath: Shape {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create curved lines emanating from center
        let centerPoint = CGPoint(x: size/2, y: size/2)
        path.move(to: centerPoint)
        
        // Break down complex angle calculations
        let baseAngle = Double(index) * .pi / 3
        let rotationFactor = rotation / 30
        let angle = baseAngle + rotationFactor
        
        // Calculate end point coordinates in steps
        let radiusFactor = size / 1.8
        let scaledRadius = radiusFactor * scale
        let xCos = cos(angle)
        let ySin = sin(angle)
        
        // Calculate endpoint
        let endPointX = centerPoint.x + xCos * scaledRadius
        let endPointY = centerPoint.y + ySin * scaledRadius
        let endPoint = CGPoint(x: endPointX, y: endPointY)
        
        // Calculate control point in steps
        let controlAngleOffset = 0.2
        let controlAngle = angle + controlAngleOffset
        
        let controlRadiusFactor = size / 3
        let scaledControlRadius = controlRadiusFactor * scale
        let controlXCos = cos(controlAngle)
        let controlYSin = sin(controlAngle)
        
        let controlPointX = centerPoint.x + controlXCos * scaledControlRadius
        let controlPointY = centerPoint.y + controlYSin * scaledControlRadius
        let controlPoint = CGPoint(x: controlPointX, y: controlPointY)
        
        // Add the curve with our calculated points
        path.addQuadCurve(
            to: endPoint,
            control: controlPoint
        )
        
        return path
    }
}

// MARK: - Enhanced Connection Node
struct EnhancedConnectionNode: View {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        // Create the circle with all calculated properties
        let nodeScale = isBreathingIn ? 1.2 : 0.8
        let nodeOpacity = 0.9 * opacity
        
        // Break down complex expressions into simple steps
        // Step 1: Calculate the base angle
        let indexMultiplier = Double(index) * .pi / 3
        
        // Step 2: Calculate rotation adjustment
        let rotationAdjustment = rotation / 30
        
        // Step 3: Calculate final angle
        let angle = indexMultiplier + rotationAdjustment
        
        // Step 4: Calculate radius for positioning
        let radius = size / 1.8 * scale
        
        // Step 5: Calculate position adjustments
        let cosValue = cos(angle)
        let sinValue = sin(angle)
        
        // Step 6: Calculate final offsets
        let centerAdjustment = size / 2
        let xOffset = cosValue * radius - centerAdjustment
        let yOffset = sinValue * radius - centerAdjustment
        
        return ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4 * nodeOpacity),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 15
                    )
                )
                .frame(width: 20, height: 20)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(nodeScale)
                .blur(radius: 2)
            
            // Main node
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9 * nodeOpacity),
                            Color.white.opacity(0.6 * nodeOpacity)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 12)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(nodeScale)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8 * nodeOpacity), lineWidth: 1)
                        .frame(width: 12, height: 12)
                        .offset(x: xOffset, y: yOffset)
                        .scaleEffect(nodeScale)
                )
        }
    }
}

// MARK: - Neural Connection Path (Legacy - keeping for compatibility)
struct NeuralConnectionPath: View {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            // Create the path for neural connections
            ConnectionPath(index: index, size: size, scale: scale, rotation: rotation)
                .stroke(
                    Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.7 * opacity),
                    lineWidth: 2
                )
            
            // Add node points at the ends
            ConnectionNode(index: index, size: size, scale: scale, rotation: rotation, opacity: opacity, isBreathingIn: isBreathingIn)
        }
    }
}

// MARK: - Connection Path (Legacy)
struct ConnectionPath: Shape {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create curved lines emanating from center
        let centerPoint = CGPoint(x: size/2, y: size/2)
        path.move(to: centerPoint)
        
        // Break down complex angle calculations
        let baseAngle = Double(index) * .pi / 3
        let rotationFactor = rotation / 30
        let angle = baseAngle + rotationFactor
        
        // Calculate end point coordinates in steps
        let radiusFactor = size / 1.8
        let scaledRadius = radiusFactor * scale
        let xCos = cos(angle)
        let ySin = sin(angle)
        
        // Calculate endpoint
        let endPointX = centerPoint.x + xCos * scaledRadius
        let endPointY = centerPoint.y + ySin * scaledRadius
        let endPoint = CGPoint(x: endPointX, y: endPointY)
        
        // Calculate control point in steps
        let controlAngleOffset = 0.2
        let controlAngle = angle + controlAngleOffset
        
        let controlRadiusFactor = size / 3
        let scaledControlRadius = controlRadiusFactor * scale
        let controlXCos = cos(controlAngle)
        let controlYSin = sin(controlAngle)
        
        let controlPointX = centerPoint.x + controlXCos * scaledControlRadius
        let controlPointY = centerPoint.y + controlYSin * scaledControlRadius
        let controlPoint = CGPoint(x: controlPointX, y: controlPointY)
        
        // Add the curve with our calculated points
        path.addQuadCurve(
            to: endPoint,
            control: controlPoint
        )
        
        return path
    }
}

// MARK: - Connection Node (Legacy)
struct ConnectionNode: View {
    let index: Int
    let size: CGFloat
    let scale: CGFloat
    let rotation: Double
    let opacity: Double
    let isBreathingIn: Bool
    
    var body: some View {
        // Create the circle with all calculated properties
        let nodeScale = isBreathingIn ? 1.1 : 0.9
        let nodeOpacity = 0.8 * opacity
        
        // Break down complex expressions into simple steps
        // Step 1: Calculate the base angle
        let indexMultiplier = Double(index) * .pi / 3
        
        // Step 2: Calculate rotation adjustment
        let rotationAdjustment = rotation / 30
        
        // Step 3: Calculate final angle
        let angle = indexMultiplier + rotationAdjustment
        
        // Step 4: Calculate radius for positioning
        let radius = size / 1.8 * scale
        
        // Step 5: Calculate position adjustments
        let cosValue = cos(angle)
        let sinValue = sin(angle)
        
        // Step 6: Calculate final offsets
        let centerAdjustment = size / 2
        let xOffset = cosValue * radius - centerAdjustment
        let yOffset = sinValue * radius - centerAdjustment
        
        return Circle()
            .fill(Color.white.opacity(nodeOpacity))
            .frame(width: 10, height: 10)
            .offset(x: xOffset, y: yOffset)
            .scaleEffect(nodeScale)
    }
}
