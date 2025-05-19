// Use case for saving an affirmation
import Foundation

class SaveAffirmationUseCase {
    private let repository: AffirmationRepository
    
    init(repository: AffirmationRepository) {
        self.repository = repository
    }
    
    func execute(_ affirmation: Affirmation) {
        repository.saveAffirmation(affirmation)
    }
}
