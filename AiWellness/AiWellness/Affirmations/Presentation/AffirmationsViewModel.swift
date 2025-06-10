// AffirmationsViewModel for state and business logic
import Foundation
import Combine

class AffirmationsViewModel: ObservableObject {
    @Published var dailyAffirmation: Affirmation?
    @Published var savedAffirmations: [Affirmation] = []
    @Published var isLocked: Bool = true
    @Published var isLoading: Bool = false
    @Published var showSavedSheet: Bool = false
    @Published var showUnlockAnimation: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTopic: AffirmationTopic? = AffirmationTopicsProvider.topics.first(where: { !$0.isLocked })
    @Published var showTopicSheet: Bool = false

    private let getDailyAffirmationUseCase: GetDailyAffirmationUseCase
    private let saveAffirmationUseCase: SaveAffirmationUseCase
    private let getSavedAffirmationsUseCase: GetSavedAffirmationsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(repository: AffirmationRepository = AffirmationRepositoryImpl()) {
        self.getDailyAffirmationUseCase = GetDailyAffirmationUseCase(repository: repository)
        self.saveAffirmationUseCase = SaveAffirmationUseCase(repository: repository)
        self.getSavedAffirmationsUseCase = GetSavedAffirmationsUseCase(repository: repository)
        loadSavedAffirmations()
    }

    func loadDailyAffirmation() {
        isLoading = true
        let topicPrompt = selectedTopic?.title ?? "General"
        getDailyAffirmationUseCase.execute(completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let affirmation):
                    self?.dailyAffirmation = affirmation
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }, topic: topicPrompt)
    }

    func unlockAffirmation() {
        showUnlockAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.isLocked = false
            self?.showUnlockAnimation = false
            self?.loadDailyAffirmation()
        }
    }
    
    func selectTopic(_ topic: AffirmationTopic) {
        selectedTopic = topic
        // Do NOT lock again when changing topic
        loadDailyAffirmationForTopic(topic)
    }
    
    private func loadDailyAffirmationForTopic(_ topic: AffirmationTopic) {
        isLoading = true
        getDailyAffirmationUseCase.execute(completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let affirmation):
                    self?.dailyAffirmation = affirmation
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }, topic: topic.title)
    }

    func saveAffirmation(_ affirmation: Affirmation) {
        saveAffirmationUseCase.execute(affirmation)
        // Unlock "First Affirmation" achievement if not already unlocked
        GamificationManager.shared.incrementAchievement("first_affirmation")
        loadSavedAffirmations()
    }

    func loadSavedAffirmations() {
        savedAffirmations = getSavedAffirmationsUseCase.execute()
    }
}
