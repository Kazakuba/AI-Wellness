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
    let role: String?

    init(content: String, sender: String, role: String? = nil) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = Date()
        self.role = role
    }
}
