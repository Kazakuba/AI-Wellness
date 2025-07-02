//
//  SavedAffirmationView.swift
//  AiWellness
//
//  Created by Kazakuba on 21. 5. 25.
//

import SwiftUI

struct SavedAffirmationView: View {
    @ObservedObject var viewModel: SavedAffirmationViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    // Show spinner centered when loading
                    VStack {
                        Spacer()
                        ProgressView("Syncing with cloud…")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else {
                    // Show your List when not loading
                    List {
                        ForEach(viewModel.filteredAffirmations) { affirmation in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(affirmation.text)
                                    .font(.body)
                                if let topic = affirmation.topic {
                                    Text(topic)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(affirmation.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: viewModel.deleteAffirmations)
                    }
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                }
            }
            .navigationTitle("Saved Affirmations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        viewModel.clearAllAffirmations()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                viewModel.loadSavedAffirmations()
            }
        }
    }
}
#Preview {
    SavedAffirmationView(viewModel: .init())
}
