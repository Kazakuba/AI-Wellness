// Use case for getting daily affirmation
import Foundation

class GetDailyAffirmationUseCase {
    private let repository: AffirmationRepository
    
    init(repository: AffirmationRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<Affirmation, Error>) -> Void) {
        repository.fetchDailyAffirmation(completion: completion)
    }
    func execute(completion: @escaping (Result<Affirmation, Error>) -> Void, topic: String?) {
        if let repoImpl = repository as? AffirmationRepositoryImpl {
            repoImpl.fetchDailyAffirmation(completion: completion, topic: topic)
        } else {
            repository.fetchDailyAffirmation(completion: completion)
        }
    }
}
