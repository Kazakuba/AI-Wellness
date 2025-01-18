//
//  ChatDetailView.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import SwiftUI

struct ChatDetailView: View {
    @ObservedObject var chatStore = ChatStore.shared
    let chat: Chat

    @State private var messageText: String = ""

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: 8) {
                        ForEach(currentChat.messages) { message in
                            // Different alignment based on who sent the message
                            if message.sender == "Me" {
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(message.sender)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(message.content)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(message.sender)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(message.content)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.gray.opacity(0.15))
                                            .cornerRadius(12)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .onChange(of: currentChat.messages.count) {
                        // Scroll to bottom when a new message is added
                        if let lastMessage = currentChat.messages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            HStack {
                TextField("Type your message...", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(chat.title)
    }

    private var currentChat: Chat {
        if let updatedChat = chatStore.chats.first(where: { $0.id == chat.id }) {
            return updatedChat
        } else {
            return chat
        }
    }

    func sendMessage() {
        chatStore.addMessage(messageText, sender: "Me", to: chat.id)
        messageText = ""
    }
}
