//
//  PersistenceService.swift
//  AiWellness
//
//  Created by Kazakuba on 14. 1. 25.
//

import Foundation

class PersistenceService {
    static var shared = PersistenceService()
    private let noteKey = "timeCapsuleNotes"
    private let archivedNoteKey = "archivedTimeCapsuleNotes"
    
    
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
    
    func resetNotesStorage() {
        UserDefaults.standard.removeObject(forKey: noteKey)
        print("Cleared saved notes from UserDefaults")
    }
    
    func deleteNote(withId id: UUID) throws {
        var notes = try fetchNote()
        notes.removeAll { $0.id == id }
        
        let encoded = try JSONEncoder().encode(notes)
        UserDefaults.standard.set(encoded, forKey: noteKey)
    }
    
    func overwriteNotes(_ notes: [TimeCapsuleNote]) throws {
        let data = try JSONEncoder().encode(notes)
        UserDefaults.standard.set(data, forKey: noteKey)
    }
    
    func archiveNote(_ note: TimeCapsuleNote) throws {
        var archivedNotes = try fetchArchivedNotes()
        archivedNotes.append(note)
        let encoded = try JSONEncoder().encode(archivedNotes)
        UserDefaults.standard.set(encoded, forKey: archivedNoteKey)
    }
    
    func fetchArchivedNotes() throws -> [TimeCapsuleNote] {
        guard let data = UserDefaults.standard.data(forKey: archivedNoteKey) else { return [] }
        return try JSONDecoder().decode([TimeCapsuleNote].self, from: data)
    }
    
    func overwriteArchivedNotes(_ notes: [TimeCapsuleNote]) throws {
        let data = try JSONEncoder().encode(notes)
        UserDefaults.standard.set(data, forKey: archivedNoteKey)
    }
    
    func clearArchivedNotes() {
        UserDefaults.standard.removeObject(forKey: archivedNoteKey)
    }
    
    func archiveExpiredNotes(_ expired: [TimeCapsuleNote]) throws {
        var archived = try fetchArchivedNotes()
        archived.append(contentsOf: expired)
        
        let archivedData = try JSONEncoder().encode(archived)
        UserDefaults.standard.set(archivedData, forKey: archivedNoteKey)
        
        var currentNotes = try fetchNote()
        currentNotes.removeAll { expired.contains($0) }
        
        let activeData = try JSONEncoder().encode(currentNotes)
        UserDefaults.standard.set(activeData, forKey: noteKey)
    }
    
    func deleteArchivedNote(withId id: UUID) throws {
        var archived = try fetchArchivedNotes()
        archived.removeAll { $0.id == id }
        
        let data = try JSONEncoder().encode(archived)
        UserDefaults.standard.set(data, forKey: archivedNoteKey)
    }
    
    func clearAllArchivedNotes() throws {
        UserDefaults.standard.removeObject(forKey: archivedNoteKey)
    }
}
