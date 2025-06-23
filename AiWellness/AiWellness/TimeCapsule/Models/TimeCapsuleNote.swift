//
//  TimeCapsuleNote.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import Foundation

// Defining TimeCapsuleNote model
struct TimeCapsuleNote: Codable, Identifiable, Equatable {
    let id: UUID
    let content: String
    let unlockDate: Date
}
