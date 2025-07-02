//
//  PersistenceService.swift
//  AiWellness
//
//  Created by Kazakuba on 14. 1. 25.
//

import Foundation

//A service which handles data persistence using UserDefaults
class PersistenceService {
    static var shared = PersistenceService()
    private let noteKey = "timeCapsuleNotes"
    private let archivedNoteKey = "archivedTimeCapsuleNotes"
    
    
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
    
    //Fetch saved notes
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
    
    //Reseting memory of UserDefaults for noteKey
    func resetNotesStorage() {
        UserDefaults.standard.removeObject(forKey: noteKey)
        print("Cleared saved notes from UserDefaults")
    }
    
    //Deleting just one note
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
    
    //
    func clearArchivedNotes() {
        UserDefaults.standard.removeObject(forKey: archivedNoteKey)
    }
    
    // Move expired notes to archive and remove from active notes
    func archiveExpiredNotes(_ expired: [TimeCapsuleNote]) throws {
        // Append to existing archived notes
        var archived = try fetchArchivedNotes()
        archived.append(contentsOf: expired)
        
        // Save updated archive
        let archivedData = try JSONEncoder().encode(archived)
        UserDefaults.standard.set(archivedData, forKey: archivedNoteKey)
        
        // Remove expired notes from current notes
        var currentNotes = try fetchNote()
        currentNotes.removeAll { expired.contains($0) }
        
        let activeData = try JSONEncoder().encode(currentNotes)
        UserDefaults.standard.set(activeData, forKey: noteKey)
    }
    
    //Deleting archieved note  bu swiping
    func deleteArchivedNote(withId id: UUID) throws {
        var archived = try fetchArchivedNotes()
        archived.removeAll { $0.id == id }
        
        let data = try JSONEncoder().encode(archived)
        UserDefaults.standard.set(data, forKey: archivedNoteKey)
    }
    
    //Clearing all archived notes
    func clearAllArchivedNotes() throws {
        UserDefaults.standard.removeObject(forKey: archivedNoteKey)
    }
}
