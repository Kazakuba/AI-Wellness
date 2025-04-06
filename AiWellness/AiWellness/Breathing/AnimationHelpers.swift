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

// MARK: - Neural Connection Path
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

// MARK: - Connection Path
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

// MARK: - Connection Node
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
