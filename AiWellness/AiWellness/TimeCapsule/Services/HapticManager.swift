//
//  HapticManager.swift
//  AiWellness
//
//  Created by Lucija Iglič on 11. 6. 25.
//

import Foundation
import UIKit

enum HapticManager {
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
