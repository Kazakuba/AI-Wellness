// Protocol for affirmation repository
import Foundation

protocol AffirmationRepository {
    func fetchDailyAffirmation(completion: @escaping (Result<Affirmation, Error>) -> Void)
    func saveAffirmation(_ affirmation: Affirmation)
    func getSavedAffirmations() -> [Affirmation]
    func isAffirmationSaved(_ affirmation: Affirmation) -> Bool
}
