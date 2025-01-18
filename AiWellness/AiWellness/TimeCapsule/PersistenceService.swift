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
    private let noteKey = "timeCapsuleNote"
    
    func saveNote(note: TimeCapsuleNote) {
       let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(note) {
            UserDefaults.standard.setValue(encoded, forKey: noteKey)
        }
    }
    
    func fetchNote() -> TimeCapsuleNote? {
        if let savedData = UserDefaults.standard.data(forKey: noteKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(TimeCapsuleNote.self, from: savedData)
        }
        return nil
    }
}
