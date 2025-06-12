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
        // --- Explorer logic ---
        let uid = GamificationManager.shared.getUserUID() ?? "default"
        let explorerKey = "explorer_topics_\(uid)"
        let defaults = UserDefaults.standard
        var topics = Set(defaults.stringArray(forKey: explorerKey) ?? [])
        let topicId = topic.id
        let wasInserted = topics.insert(topicId).inserted
        if wasInserted {
            defaults.set(Array(topics), forKey: explorerKey)
            let count = topics.count
            // Update achievement progress (goal: 5)
            if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "explorer" }) {
                GamificationManager.shared.achievements[idx].progress = count
                GamificationManager.shared.achievements[idx].isUnlocked = (count >= 5)
            }
            // Update badge progress using milestone-based system
            GamificationManager.shared.incrementBadge("explorer")
            GamificationManager.shared.save()
        }
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
        // --- Collector logic ---
        let uid = GamificationManager.shared.getUserUID() ?? "default"
        let collectorKey = "collector_count_\(uid)"
        let defaults = UserDefaults.standard
        var count = defaults.integer(forKey: collectorKey)
        // Only increment if this is a new save
        if !savedAffirmations.contains(where: { $0.id == affirmation.id }) {
            count += 1
            defaults.set(count, forKey: collectorKey)
        }
        // Update achievement progress (goal: 10)
        if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "collector" }) {
            GamificationManager.shared.achievements[idx].progress = count
            GamificationManager.shared.achievements[idx].isUnlocked = (count >= 10)
        }
        // Update badge progress using milestone-based system
        GamificationManager.shared.incrementBadge("collector")
        GamificationManager.shared.save()
        loadSavedAffirmations()
    }

    func loadSavedAffirmations() {
        savedAffirmations = getSavedAffirmationsUseCase.execute()
    }
}
