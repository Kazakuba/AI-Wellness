//
//  TimeCapsuleView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 14. 1. 25.
//
import SwiftUI

struct TimeCapsuleView: View {
    @Binding var isPresented: Bool
    @State private var viewModel = TimeCapsuleViewModel()

    var body: some View {
        ZStack {
            BackgroundGradient()
            VStack(spacing: 20) {
                HStack {
                    IconButton(icon: "xmark", title: "") {
                        isPresented = false
                    }
                    Spacer()
                }
                //Title
                Text("Write A Note To Your Future Self ")
                    .font(Typography.Font.heading2)
                    .padding()
                //Text Input Field
                TextFieldComponent(text: $viewModel.noteContent , placeholder: "Type your note here...")
                    .padding()
                // Picker for Timeframe
                Picker("Select Timeframe", selection: $viewModel.selectedTimeframe) {
                    ForEach(viewModel.timeframes, id: \.self) { timeframe in
                        Text(timeframe).tag(timeframe)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(ColorPalette.buttonBackground)
                    .cornerRadius(10)
                }
                // Save Note Button
                PrimaryButton(title: "Save Note") {
                    if viewModel.saveNote() {
                        viewModel.showConfirmation = true
                    }
                }
                //TESTING - Remove notes button, will remove button later
                PrimaryButton(title: "Remove all notes", action: {
                    viewModel.debugResetUserDefaults()
                })
                .padding()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(ColorPalette.buttonBackground)
                }
                
                //TESTING - A list of saved notes, will remove list later
                List(viewModel.savedNotes) { note in
                    VStack(alignment: .leading) {
                        Text(note.content)
                            .font(.headline)
                        Text("Unlocks on \(note.unlockDate, formatter: DateFormatter.short)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    viewModel.fetchNote() // TESTING
                }
            }
            .padding()
            .alert(isPresented: $viewModel.showConfirmation) {
                Alert(title: Text("Note Saved!"),
                      message: Text("Your note is locked until \(viewModel.selectedTimeframe)"),
                      dismissButton: .default(Text("OK")) {
                    // Dismiss the view only after confirmation alert is dismissed
                    isPresented = false
                }
                )
            }
        }
    }
}

#Preview {
    TimeCapsuleView(isPresented: .constant(true))
}

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemGray4), Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}
