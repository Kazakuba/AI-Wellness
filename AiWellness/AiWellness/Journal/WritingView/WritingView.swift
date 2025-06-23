//
//  WritingView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//
import SwiftUI
import FirebaseAuth
import ConfettiSwiftUI

struct WritingView: View {
    // MARK: - Properties
    let selectedDate: Date
    @State private var text: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var confettiManager = ConfettiManager.shared
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            dateHeader
            journalEditor
        }
        .padding()
        .background(ColorPalette.background)
        .onAppear(perform: loadText)
        .onChange(of: selectedDate) { _, _ in
            loadText()
        }
        .onChange(of: Auth.auth().currentUser?.uid) { _, _ in
            loadText()
        }
        .confettiCannon(trigger: $confettiManager.trigger, num: 40, colors: [.yellow, .green, .blue, .orange])
    }
    
    // MARK: - UI Components
    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getFormattedDate(selectedDate))
            //Make custom fonts
                .font(.system(.title2, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.top, 8)
    }
    
    private var journalEditor: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .serif))
            .lineSpacing(5)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ?
                          ColorPalette.background :
                          ColorPalette.background)
                    .shadow(
                        color: .gray.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .frame(maxHeight: .infinity)
            .onChange(of: text) { oldValue, newValue in
                saveText(newValue)
                
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                let uid = GamificationManager.shared.getUserUID() ?? "default"
                let defaults = UserDefaults.standard
                
                // --- Journal Initiate achievement logic ---
                let journalKey = "journal_initiate_\(uid)"
                let hasWrittenBefore = defaults.bool(forKey: journalKey)
                if !hasWrittenBefore {
                    defaults.set(true, forKey: journalKey)
                    // Unlock "Journal Initiate" achievement
                    GamificationManager.shared.incrementAchievement("journal_initiate")
                }
                
                // --- Journal Master badge logic ---
                let journalMasterKey = "journal_master_entries_\(uid)"
                var completedDates = Set(defaults.stringArray(forKey: journalMasterKey) ?? [])
                let dateString = ISO8601DateFormatter().string(from: selectedDate)
                if !completedDates.contains(dateString) {
                    completedDates.insert(dateString)
                    defaults.set(Array(completedDates), forKey: journalMasterKey)
                    // Update Journal Master badge progress
                    GamificationManager.shared.incrementBadge("journal_master")
                }
                
                GamificationManager.shared.save()
            }
    }
    
    // MARK: - Helper Methods
    private func saveText(_ text: String) {
        WritingDataManager.shared.saveText(text, for: selectedDate)
    }
    
    private func loadText() {
        text = WritingDataManager.shared.getText(for: selectedDate)
    }
    
    private func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    WritingView(selectedDate: Date())
}
