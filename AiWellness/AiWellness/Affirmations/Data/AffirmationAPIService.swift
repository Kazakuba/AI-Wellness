// Data layer: Google API service for affirmations (reference GeminiAPIService)
import Foundation

class AffirmationAPIService {
    func fetchAffirmation(completion: @escaping (Result<Affirmation, Error>) -> Void, topic: String? = nil) {
        let prompt: String
        if let topic = topic, !topic.isEmpty {
            prompt = "Generate a unique, positive, short daily affirmation about \(topic). Return only the affirmation text."
        } else {
            prompt = "Generate a unique, positive, short daily affirmation for personal growth. Return only the affirmation text."
        }
        GeminiAPIService.shared.sendMessage(prompt, chatHistory: []) { result in
            switch result {
            case .success(let text):
                let affirmation = Affirmation(id: UUID(), text: text.trimmingCharacters(in: .whitespacesAndNewlines), date: Date(), topic: topic, isFavorite: false)
                completion(.success(affirmation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
