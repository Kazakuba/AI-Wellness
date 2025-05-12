//
//  ChatCompletionResponse.swift
//  AiWellness
//
//  Created by Kazakuba on 18.1.25..
//

struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
        let finish_reason: String
    }
    let id: String
    let object: String
    let created: Int
    let model: String
    let system_fingerprint: String
    let choices: [Choice]
    let usage: Usage?

    struct Usage: Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}
