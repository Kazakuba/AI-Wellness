//
//  PersistenceService.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//

import Foundation

//A service which handles data persistence using UserDefaults
class PersistenceService {
    static var shared = PersistenceService()
    private let noteKey = "timeCapsuleNotes"
    
    // Saving single note into the array of notes
    func saveNote(note: TimeCapsuleNote) throws {
        let encoder = JSONEncoder()
        do {
            var notes = try fetchNote()
            notes.append(note)
            let encoded = try encoder.encode(notes)
            UserDefaults.standard.setValue(encoded, forKey: noteKey)
        } catch {
            throw error
        }
    }
    
    //Fetch all saved notes
    func fetchNote() throws -> [TimeCapsuleNote] {
        guard let savedData = UserDefaults.standard.data(forKey: noteKey) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([TimeCapsuleNote].self, from: savedData)
        } catch {
            throw error
        }
    }
    
    func debugResetUserDefaults() {
        UserDefaults.standard.removeObject(forKey: noteKey)
        print("Cleared saved notes from UserDefaults")
    }
}
