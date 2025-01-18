//
//  Chat.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    var createdDate: Date

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.messages = []
        self.createdDate = Date()
    }
}
