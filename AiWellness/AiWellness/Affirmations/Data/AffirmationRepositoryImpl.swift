// Data layer: Google API and local persistence implementation
import Foundation

class AffirmationRepositoryImpl: AffirmationRepository {
    private let apiService: AffirmationAPIService
    private let persistence: AffirmationPersistence
    
    @Published var searchText: String = ""
    @Published var affirmations: [Affirmation] = []
    
    init(apiService: AffirmationAPIService = AffirmationAPIService(),
         persistence: AffirmationPersistence = AffirmationPersistence()) {
        self.apiService = apiService
        self.persistence = persistence
    }
    
    func fetchDailyAffirmation(completion: @escaping (Result<Affirmation, Error>) -> Void, topic: String? = nil) {
        let uid = GamificationManager.shared.getUserUID()
        if let cached = persistence.getTodayAffirmation(for: topic, uid: uid) {
            completion(.success(cached))
            return
        }
        let previousAffirmations = persistence.getSavedAffirmations(uid: uid).filter { $0.topic == topic }
        func fetchUniqueAffirmation(retry: Int = 0) {
            apiService.fetchAffirmation(completion: { result in
                switch result {
                case .success(let affirmation):
                    if previousAffirmations.contains(where: { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == affirmation.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
                        if retry < 5 {
                            fetchUniqueAffirmation(retry: retry + 1)
                        } else {
                            self.persistence.saveTodayAffirmation(affirmation, uid: uid)
                            completion(.success(affirmation))
                        }
                    } else {
                        self.persistence.saveTodayAffirmation(affirmation, uid: uid)
                        completion(.success(affirmation))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }, topic: topic)
        }
        fetchUniqueAffirmation()
    }
    
    func fetchDailyAffirmation(completion: @escaping (Result<Affirmation, Error>) -> Void) {
        fetchDailyAffirmation(completion: completion, topic: nil)
    }
    
    func saveAffirmation(_ affirmation: Affirmation) {
        let uid = GamificationManager.shared.getUserUID()
        persistence.saveAffirmation(affirmation, uid: uid)
        FirestoreManager.shared.uploadAffirmation(affirmation) { result in
            switch result {
            case .success():
                print("Saved to Firestore")
            case .failure(let error):
                print("Error saving to Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    func getSavedAffirmations() -> [Affirmation] {
        let uid = GamificationManager.shared.getUserUID()
        return persistence.getSavedAffirmations(uid: uid)
    }
    
    func isAffirmationSaved(_ affirmation: Affirmation) -> Bool {
        let uid = GamificationManager.shared.getUserUID()
        return persistence.isAffirmationSaved(affirmation, uid: uid)
    }
}
