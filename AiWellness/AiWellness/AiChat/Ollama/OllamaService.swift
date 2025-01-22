//
//  OllamaService.swift
//  AiWellness
//
//  Created by Kazakuba on 18.1.25..
//

import Foundation

class OllamaService {
    static let shared = OllamaService()
    private init() {}

    private let baseURL = URL(string: "http://127.0.0.1:11434")!

    func sendMessage(chatID: UUID, message: String, completion: @escaping (Result<Message, Error>) -> Void) {
        let endpoint = baseURL.appendingPathComponent("/v1/chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request payload
        let body: [String: Any] = [
            "model": "llama3.2",
            "stream": false,
            "format": "json",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": message]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "HTTP Error", code: -1, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                if let firstChoice = chatResponse.choices.first {
                    let responseMessage = Message(content: firstChoice.message.content, sender: "Ollama")
                    completion(.success(responseMessage))
                } else {
                    completion(.failure(NSError(domain: "No choices in response", code: -1, userInfo: nil)))
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
                completion(.failure(error))
            }
        }.resume()
    }

    func checkServerStatus(completion: @escaping (Bool) -> Void) {
        let endpoint = baseURL
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let responseString = String(data: data, encoding: .utf8),
               responseString.contains("Ollama is running") {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}
