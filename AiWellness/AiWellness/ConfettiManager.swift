import Foundation
import Combine
import ConfettiSwiftUI

class ConfettiManager: ObservableObject {
    static let shared = ConfettiManager()
    @Published var trigger: Int = 0
    @Published var confettis: [ConfettiType] = [.shape(.circle), .shape(.triangle), .shape(.square), .shape(.slimRectangle), .shape(.roundedCross)]

    private let allConfettiTypes: [[ConfettiType]] = [
        [.shape(.circle), .shape(.triangle), .shape(.square), .shape(.slimRectangle), .shape(.roundedCross)],
        [.text("🎉"), .text("💚"), .text("💙"), .text("❤️")],
        [.sfSymbol(symbolName: "star.fill"), .sfSymbol(symbolName: "heart.fill")],
        [.text("💩"), .text("💵"), .text("💶"), .text("💷"), .text("💴")],
        [.shape(.circle), .text("🎉"), .sfSymbol(symbolName: "star.fill")],
        [.shape(.roundedCross), .shape(.slimRectangle)],
        [.sfSymbol(symbolName: "flame.fill"), .sfSymbol(symbolName: "bolt.fill")]
    ]

    private init() {}

    func celebrate() {
        if let random = allConfettiTypes.randomElement() {
            confettis = random
        }
        trigger += 1
    }
} 
