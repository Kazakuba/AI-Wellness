//
//  FirestoreManager.swift
//  AiWellness
//
//  Created by Kazakuba on 27. 4. 25.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func uploadAffirmation(_ affirmation: Affirmation, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "id": affirmation.id.uuidString,
            "text": affirmation.text,
            "date": Timestamp(date: affirmation.date),
            "topic": affirmation.topic ?? "",           // optional handled
            "isFavorite": affirmation.isFavorite        // store bool in Firestore
        ]
        
        db.collection("affirmations")  // 👈 use plural
            .document(affirmation.id.uuidString)
            .setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func fetchSavedAffirmations(completion: @escaping ([Affirmation]) -> Void) {
        db.collection("affirmations").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            let affirmations: [Affirmation] = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let text = data["text"] as? String,
                    let timestamp = data["date"] as? Timestamp
                else {
                    return nil
                }
                return Affirmation(
                    id: id,
                    text: text,
                    date: timestamp.dateValue(),
                    topic: data["topic"] as? String,
                    isFavorite: data["isFavorite"] as? Bool ?? false
                )
            }
            completion(affirmations)
        }
    }
    // Deleting saved affirmation from Firestore Database
    func deleteAffirmation(_ affirmation: Affirmation, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("affirmations")
            .document(affirmation.id.uuidString)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func clearAllAffirmations(completion: @escaping (Result<Void, Error>) -> Void) {
            let db = Firestore.firestore()
            let affirmationsRef = db.collection("affirmations")

            affirmationsRef.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let batch = db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                batch.commit { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
}
