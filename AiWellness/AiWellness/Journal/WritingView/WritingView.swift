//
//  WritingView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//
import SwiftUI
import FirebaseAuth

struct WritingView: View {
    // MARK: - Properties
    let selectedDate: Date
    @State private var text: String = ""
    @Environment(\.colorScheme) private var colorScheme
    
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
                // --- Journal Hero achievement logic ---
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                let uid = GamificationManager.shared.getUserUID() ?? "default"
                let journalKey = "journal_hero_dates_\(uid)"
                let defaults = UserDefaults.standard
                var completedDates = Set(defaults.stringArray(forKey: journalKey) ?? [])
                let dateString = ISO8601DateFormatter().string(from: selectedDate)
                if !completedDates.contains(dateString) {
                    completedDates.insert(dateString)
                    defaults.set(Array(completedDates), forKey: journalKey)
                    // Update achievement progress (goal: 5)
                    if let idx = GamificationManager.shared.achievements.firstIndex(where: { $0.id == "journal_hero" }) {
                        GamificationManager.shared.achievements[idx].progress = completedDates.count
                        GamificationManager.shared.achievements[idx].isUnlocked = (completedDates.count >= 5)
                    }
                    GamificationManager.shared.save()
                }
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
