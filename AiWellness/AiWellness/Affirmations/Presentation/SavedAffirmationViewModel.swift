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
                // Trigger UI update; or you can filter inside the View instead
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
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
        // Load local saved affirmations first (fast)
        savedAffirmations = persistence.getSavedAffirmations()
        
        
        //Sync in progress
        isLoading = true
        
        // Fetch from Firestore and sync local storage
        fetchAndSyncFromFirestore { [weak self] in
            DispatchQueue.main.async {
                self?.savedAffirmations = self?.persistence.getSavedAffirmations() ?? []
                
                // Calculate elapsed time
                let elapsed = Date().timeIntervalSince(Date())
                let delay = max(0, 0.5 - elapsed)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self?.isLoading = false
                }
            }
        }
    }
    
    func fetchAndSyncFromFirestore(completion: @escaping () -> Void) {
            FirestoreManager.shared.fetchSavedAffirmations { [weak self] cloudAffirmations in
                guard let self = self else { return }
                let localAffirmations = self.persistence.getSavedAffirmations()
                let combined = (localAffirmations + cloudAffirmations).uniqued()
                self.persistence.saveAffirmations(combined)
                completion()
            }
        }
    
    //Deleting saved affirmation
    func deleteAffirmation(_ affirmation: Affirmation) {
        // Delete locally
        persistence.deleteAffirmation(affirmation)
        
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
        savedAffirmations = persistence.getSavedAffirmations()
    }
    
    func deleteAffirmations(at offsets: IndexSet) {
        for index in offsets {
            let affirmation = savedAffirmations[index]
            deleteAffirmation(affirmation)
        }
    }
    
    func clearAllAffirmations() {
        // Clear local storage
        persistence.clearAllAffirmations()

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
