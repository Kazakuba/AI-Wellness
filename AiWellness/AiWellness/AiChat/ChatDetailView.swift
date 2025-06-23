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
    @ObservedObject var serverStatusViewModel: ServerStatusViewModel
    @State private var messageText: String = ""
    @State private var isFirstMessageSent = false
    @State private var isGeneratingTitle = false

    var body: some View {
        VStack {
            // Remove duplicate title, rely on navigationTitle only
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: 8) {
                        ForEach(currentChat.messages) { message in
                            // Message bubbles
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isGeneratingTitle)
                Button(action: {
                    guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    
                    // --- AI Chat Starter achievement logic ---
                    let uid = GamificationManager.shared.getUserUID() ?? "default"
                    let chatKey = "ai_chat_starter_\(uid)"
                    let defaults = UserDefaults.standard
                    let hasChattedBefore = defaults.bool(forKey: chatKey)
                    if !hasChattedBefore {
                        defaults.set(true, forKey: chatKey)
                        // Unlock "AI Chat Starter" achievement
                        GamificationManager.shared.incrementAchievement("ai_chat_starter")
                        GamificationManager.shared.save()
                    }
                    
                    // --- AI Conversationalist badge logic ---
                    let aiConversationalistKey = "ai_conversationalist_sessions_\(uid)"
                    var completedSessions = defaults.integer(forKey: aiConversationalistKey)
                    completedSessions += 1
                    defaults.set(completedSessions, forKey: aiConversationalistKey)
                    // Update AI Conversationalist badge progress
                    GamificationManager.shared.incrementBadge("ai_conversationalist")
                    GamificationManager.shared.save()
                    
                    if chat.messages.isEmpty {
                        print("[DEBUG] Generating title for first message: \(messageText)")
                        isGeneratingTitle = true
                        GeminiAPIService.shared.generateTitle(for: messageText) { result in
                            DispatchQueue.main.async {
                                isGeneratingTitle = false
                                switch result {
                                case .success(let titles):
                                    print("[DEBUG] Gemini returned titles: \(titles)")
                                    let title = titles.randomElement()?.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if let title = title, !title.isEmpty, let idx = chatStore.chats.firstIndex(where: { $0.id == chat.id }) {
                                        print("[DEBUG] Updating chat title to: \(title)")
                                        chatStore.chats[idx].title = title
                                        chatStore.saveChatsToUserDefaults()
                                    } else {
                                        print("[DEBUG] No valid title returned, keeping placeholder.")
                                    }
                                case .failure(let error):
                                    print("[DEBUG] Failed to generate title: \(error)")
                                }
                            }
                        }
                    }
                    chatStore.sendMessageUsingGeminiAPI(content: messageText, sender: "Me", chatID: chat.id)
                    messageText = ""
                }) {
                    Text("Send")
                }
                .disabled(isGeneratingTitle)
            }
            .padding()
        }
        .navigationTitle(currentChat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(serverStatusViewModel.isServerUp == true ? Color.green : (serverStatusViewModel.isServerUp == false ? Color.red : Color.gray))
                        .frame(width: 10, height: 10)
                    Text(serverStatusViewModel.isServerUp == true ? "Server is Up" : "Server is Down")
                        .font(.caption2)
                }
            }
        }
    }

    private var currentChat: Chat {
        chatStore.chats.first(where: { $0.id == chat.id }) ?? chat
    }

    func sendMessage() {
        chatStore.sendMessageUsingGeminiAPI(content: messageText, sender: "Me", chatID: chat.id)
        messageText = ""
    }
}
