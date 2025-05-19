// AffirmationTopic model for topic selection UI
import Foundation
import SwiftUI

struct AffirmationTopic: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let iconName: String
    let isLocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, iconName, isLocked
    }
    
    init(id: String, title: String, iconName: String, isLocked: Bool = false) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.isLocked = isLocked
    }
}
