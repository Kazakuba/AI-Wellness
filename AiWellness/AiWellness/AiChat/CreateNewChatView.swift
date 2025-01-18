//
//  CreateNewChatView.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import SwiftUI

struct CreateNewChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chatStore = ChatStore.shared
    @State private var chatTitle: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chat Title")) {
                    TextField("Enter a title...", text: $chatTitle)
                }
            }
            .navigationBarTitle("New Chat", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        _ = chatStore.createNewChat(title: chatTitle)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(chatTitle.isEmpty)
                }
            }
        }
    }
}
