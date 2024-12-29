//
//  WritingView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//
import SwiftUI

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
