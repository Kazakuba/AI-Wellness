// Affirmation entity for clean architecture domain layer
import Foundation

struct Affirmation: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let date: Date
    let topic: String?
    var isFavorite: Bool
}
