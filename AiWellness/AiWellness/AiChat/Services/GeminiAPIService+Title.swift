// GeminiAPIService+Title.swift

import Foundation

extension GeminiAPIService {
    func generateTitle(for message: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(GeminiAPIService.shared.apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = "Generate 3 short, catchy, and clean titles for a chat based on this message: \"\(message)\". Return only the titles as a JSON array of strings. Respond ONLY with the JSON array, no explanation or extra text."
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    print("[DEBUG] Gemini raw title response: \(text)")
                    if let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]") {
                        let jsonArrayString = String(text[start...end])
                        if let titlesData = jsonArrayString.data(using: .utf8),
                           let titles = try? JSONDecoder().decode([String].self, from: titlesData) {
                            completion(.success(titles))
                            return
                        }
                    }
                }
                completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
