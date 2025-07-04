//
//  ArchivedNotesView.swift
//  AiWellness
//
//  Created by Kazakuba on 6. 6. 25.
//

import SwiftUI

struct ArchivedNotesView: View {
    @ObservedObject var viewModel: TimeCapsuleViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if viewModel.archivedNotes.isEmpty {
                        Text("No archived notes yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.archivedNotes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.content)
                                    .font(.body)
                                    .lineLimit(5)
                                Text("Unlocked on \(formattedDate(note.unlockDate))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deleteArchivedNote)
                    }
                }
                
                if !viewModel.archivedNotes.isEmpty {
                    Button(role: .destructive) {
                        viewModel.deleteAllArchivedNotes()
                    } label: {
                        Label("Remove All Archived Notes", systemImage: "trash")
                            .padding(.vertical, 8)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Archived Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                viewModel.fetchArchivedNotes()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }

    private func deleteArchivedNote(at offsets: IndexSet) {
            for index in offsets {
                let note = viewModel.archivedNotes[index]
                viewModel.deleteArchivedNote(note)
            }
        }
}

#Preview {
    let viewModel = TimeCapsuleViewModel()
    viewModel.archivedNotes = [
        TimeCapsuleNote(
            id: UUID(),
            content: "This is a past note from the time capsule.",
            unlockDate: Date().addingTimeInterval(-86400)
        ),
        TimeCapsuleNote(
            id: UUID(),
            content: "Another inspirational note from the past.",
            unlockDate: Date().addingTimeInterval(-604800)
        )
    ]
    return ArchivedNotesView(viewModel: viewModel)
}
