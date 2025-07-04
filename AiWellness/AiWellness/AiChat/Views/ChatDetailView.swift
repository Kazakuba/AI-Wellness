//
//  ChatDetailView.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.sender != "Me" {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Gradients.aiChatAIBubble)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text(formattedTimestamp)
                        .font(.caption2)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                Spacer()
            } else {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Gradients.aiChatUserBubble)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text(formattedTimestamp)
                        .font(.caption2)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            }
        }
        .padding(.horizontal, 8)
    }
}

struct ChatDetailView: View {
    @ObservedObject var chatStore = ChatStore.shared
    let chat: Chat
    @ObservedObject var serverStatusViewModel: ServerStatusViewModel
    @State private var messageText: String = ""
    @State private var isFirstMessageSent = false
    @State private var isGeneratingTitle = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        ZStack {
            Gradients.aiChatMainBackground(isDarkMode: isDarkMode).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack(spacing: 16) {
                            ForEach(currentChat.messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding(.vertical)
                        .onChange(of: currentChat.messages.count) {
                            if let lastMessage = currentChat.messages.last {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    TextField("Type message here...", text: $messageText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.customSystemGray6)
                        .cornerRadius(20)
                        .disabled(isGeneratingTitle)
                    
                    Button(action: {
                        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        
                        let uid = GamificationManager.shared.getUserUID() ?? "default"
                        let chatKey = "ai_chat_starter_\(uid)"
                        let defaults = UserDefaults.standard
                        let hasChattedBefore = defaults.bool(forKey: chatKey)
                        if !hasChattedBefore {
                            defaults.set(true, forKey: chatKey)
                            if GamificationManager.shared.incrementAchievement("ai_chat_starter") {
                                ConfettiManager.shared.celebrate()
                            }
                            GamificationManager.shared.save()
                        }
                        
                        let aiConversationalistKey = "ai_conversationalist_sessions_\(uid)"
                        var completedSessions = defaults.integer(forKey: aiConversationalistKey)
                        completedSessions += 1
                        defaults.set(completedSessions, forKey: aiConversationalistKey)
                        if GamificationManager.shared.incrementBadge("ai_conversationalist") {
                            ConfettiManager.shared.celebrate()
                        }
                        GamificationManager.shared.save()
                        
                        if chat.messages.isEmpty {
                            isGeneratingTitle = true
                            GeminiAPIService.shared.generateTitle(for: messageText) { result in
                                DispatchQueue.main.async {
                                    isGeneratingTitle = false
                                    switch result {
                                    case .success(let titles):
                                        let title = titles.randomElement()?.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if let title = title, !title.isEmpty, let idx = chatStore.chats.firstIndex(where: { $0.id == chat.id }) {
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
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    .disabled(isGeneratingTitle)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.bottom, 16)
                .background(.clear)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text("Back")
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text(currentChat.title)
                    .foregroundColor(isDarkMode ? .white : .black)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(serverStatusViewModel.isServerUp == true ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(serverStatusViewModel.isServerUp == true ? "Server is Up" : "Server is Down")
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var currentChat: Chat {
        chatStore.chats.first(where: { $0.id == chat.id }) ?? chat
    }
}
