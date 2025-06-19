import Foundation
import Combine

class ConfettiManager: ObservableObject {
    static let shared = ConfettiManager()
    @Published var trigger: Int = 0

    private init() {}

    func celebrate() {
        trigger += 1
    }
} 