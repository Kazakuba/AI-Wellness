//
//  SavedAffirmationViewMOdel.swift
//  AiWellness
//
//  Created by Lucija Iglič on 21. 5. 25.
//

import Foundation
import Combine

class SavedAffirmationViewModel: ObservableObject {
    private let persistence = AffirmationPersistence()
    private var cancellables = Set<AnyCancellable>()

    @Published var savedAffirmations: [Affirmation] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false


    private let getSavedAffirmationsUseCase: GetSavedAffirmationsUseCase

    init(repository: AffirmationRepository = AffirmationRepositoryImpl()) {
        self.getSavedAffirmationsUseCase = GetSavedAffirmationsUseCase(repository: repository)
        loadSavedAffirmations()
        
        // Automatically filter as searchText changes (optional, you can also filter in view)
        $searchText
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Listen for account/user changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadOnUserChange), name: .journalUserDidChange, object: nil)
    }

    @objc private func reloadOnUserChange() {
        loadSavedAffirmations()
    }

    // Computed property for filtered affirmations based on searchText
    var filteredAffirmations: [Affirmation] {
        if searchText.isEmpty {
            return savedAffirmations.sorted { $0.date > $1.date }
        } else {
            return savedAffirmations
                .filter { $0.text.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.date > $1.date }
        }
    }
    
    func loadSavedAffirmations() {
        DispatchQueue.main.async {
            self.savedAffirmations = self.getSavedAffirmationsUseCase.execute()
            self.isLoading = false
        }
    }
    
    func fetchAndSyncFromFirestore(completion: @escaping () -> Void) {
        let uid = GamificationManager.shared.getUserUID()
        FirestoreManager.shared.fetchSavedAffirmations { [weak self] cloudAffirmations in
            guard let self = self else { return }
            let localAffirmations = self.persistence.getSavedAffirmations(uid: uid)
            let combined = (localAffirmations + cloudAffirmations).uniqued()
            self.persistence.saveAffirmations(combined, uid: uid)
            completion()
        }
    }
    
    //Deleting saved affirmation
    func deleteAffirmation(_ affirmation: Affirmation) {
        let uid = GamificationManager.shared.getUserUID()
        // Delete locally
        persistence.deleteAffirmation(affirmation, uid: uid)
        
        // Delete in Firestore
        FirestoreManager.shared.deleteAffirmation(affirmation) { result in
            switch result {
            case .success():
                print("Deleted from Firestore")
            case .failure(let error):
                print("Error deleting from Firestore: \(error.localizedDescription)")
            }
        }
        
        // Update local list
        savedAffirmations = persistence.getSavedAffirmations(uid: uid)
    }
    
    func deleteAffirmations(at offsets: IndexSet) {
        for index in offsets {
            let affirmation = savedAffirmations[index]
            deleteAffirmation(affirmation)
        }
    }
    
    func clearAllAffirmations() {
        let uid = GamificationManager.shared.getUserUID()
        // Clear local storage
        persistence.clearAllAffirmations(uid: uid)

        // Clear Firestore
        FirestoreManager.shared.clearAllAffirmations { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("All affirmations cleared from Firestore")
                    self?.savedAffirmations.removeAll()
                case .failure(let error):
                    print("Failed to clear affirmations from Firestore: \(error)")
                }
            }
        }

        // Update local list
        savedAffirmations.removeAll()
    }
}

extension Array where Element == Affirmation {
    func uniqued() -> [Affirmation] {
        var seenIds = Set<UUID>()
        return filter { seenIds.insert($0.id).inserted }
    }
}
