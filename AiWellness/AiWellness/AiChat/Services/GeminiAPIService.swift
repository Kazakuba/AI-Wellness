import Foundation

class GeminiAPIService {
    static let shared = GeminiAPIService()
    let apiKey = "AIzaSyBfgFc-qoRFmeeayvYqKYbH7yhoHanW9DM" // TODO: Move to environment/config for production
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    private init() {}

    func sendMessage(_ message: String, chatHistory: [Message], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let historyParts = chatHistory.map { ["text": $0.content] }
        let body: [String: Any] = [
            "contents": [
                ["parts": historyParts + [["text": message]]]
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
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received from API.")
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let rawResponse = try JSONSerialization.jsonObject(with: data, options: [])
                print("Raw Response: \(rawResponse)")

                if let json = rawResponse as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(.success(text))
                } else {
                    print("Invalid response format: \(rawResponse)")
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func ping(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": "ping"]]]
            ]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}
