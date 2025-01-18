//
//  Message.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let sender: String
    let timestamp: Date

    init(content: String, sender: String) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = Date()
    }
}
