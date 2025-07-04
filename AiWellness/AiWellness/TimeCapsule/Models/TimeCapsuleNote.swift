//
//  TimeCapsuleNote.swift
//  AiWellness
//
//  Created by Kazakuba on 14. 1. 25.
//

import Foundation

struct TimeCapsuleNote: Codable, Identifiable, Equatable {
    let id: UUID
    let content: String
    let unlockDate: Date
}
