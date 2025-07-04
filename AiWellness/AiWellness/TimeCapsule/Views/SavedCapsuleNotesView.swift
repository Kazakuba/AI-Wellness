//
//  SavedCapsuleNotesView.swift
//  AiWellness
//
//  Created by Kazakuba on 4. 6. 25.
//

import SwiftUI

struct SavedCapsuleNotesView: View {
    @ObservedObject var viewModel: TimeCapsuleViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.savedNotes, id: \.id) { note in
                        VStack(alignment: .leading) {
                            Text(note.content)
                                .font(.headline)
                            Text("Unlocks on \(note.unlockDate, formatter: DateFormatter.short)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let note = viewModel.savedNotes[index]
                            viewModel.deleteNote(note)
                        }
                    }
                }

                Button("Remove All Notes", systemImage: "trash") {
                    viewModel.resetNotesStorage()
                    viewModel.fetchNote()
                    HapticManager.trigger(.heavy)
                }
                .padding()
                .foregroundColor(.red)
            }
            .navigationTitle("Saved Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.fetchNote()
            viewModel.archiveExpiredNotes()
            viewModel.fetchArchivedNotes()
        }
    }
}

#Preview {
    let mockViewModel = TimeCapsuleViewModel()
    mockViewModel.savedNotes = [
        TimeCapsuleNote(id: UUID(), content: "Mock Note 1", unlockDate: Date().addingTimeInterval(3600)),
        TimeCapsuleNote(id: UUID(), content: "Mock Note 2", unlockDate: Date().addingTimeInterval(7200))
    ]
    return SavedCapsuleNotesView(viewModel: mockViewModel)
}
