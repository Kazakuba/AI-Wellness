// Use case for getting saved affirmations
import Foundation

class GetSavedAffirmationsUseCase {
    private let repository: AffirmationRepository
    
    init(repository: AffirmationRepository) {
        self.repository = repository
    }
    
    func execute() -> [Affirmation] {
        return repository.getSavedAffirmations()
    }
}
