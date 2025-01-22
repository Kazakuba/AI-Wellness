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
                        createChat()
                    }
                    .disabled(chatTitle.isEmpty)
                }
            }
        }
    }

    private func createChat() {
        _ = chatStore.createNewChat(title: chatTitle)
//        let systemMessage = Message(content: "You are a helpful assistant.", sender: "System", role: "system")
//        chatStore.addMessage(systemMessage.content, sender: systemMessage.sender, to: newChat.id)
        presentationMode.wrappedValue.dismiss()
    }
}
