// MotionManager for shake detection (UIKit integration)
import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var lastShakeDate: Date?
    @Published var didShake: Bool = false
    
    init() {
        startAccelerometerUpdates()
    }
    
    private func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            let acceleration = data.acceleration
            let magnitude = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
            if magnitude > 2.3 { // Shake threshold
                let now = Date()
                if let last = self.lastShakeDate, now.timeIntervalSince(last) < 1.0 {
                    return // Prevent multiple triggers
                }
                self.lastShakeDate = now
                self.didShake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.didShake = false
                }
            }
        }
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
