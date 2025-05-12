//
//  ChatListView.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import Foundation
import SwiftUI

struct ChatListView: View {
    @ObservedObject var chatStore = ChatStore.shared
    @State private var isShowingMoreOptions = false
    @StateObject private var serverStatusViewModel = ServerStatusViewModel()
    @State private var isShowingAlert = false
    @State private var navigateToChat: Chat? = nil

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        isShowingAlert = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .alert(isPresented: $isShowingAlert) {
                        Alert(
                            title: Text("Server Information"),
                            message: Text(
                                serverStatusViewModel.isServerUp == true
                                ? "The AI system is up and running."
                                : "The AI system is currently unavailable. Please try again later."
                            ),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    Spacer()

                    Text("ChatAI")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        isShowingMoreOptions.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)

                Button(action: {
                    // Create a new chat with a placeholder title and navigate to it
                    let newChat = chatStore.createNewChat(title: "New Chat")
                    navigateToChat = newChat
                }) {
                    Text("Create New Chats")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)

                HStack {
                    Text("Chats History")
                        .font(.title2)
                        .bold()

                    Spacer()

                    Circle()
                        .fill(serverStatusViewModel.isServerUp == true ? Color.green : (serverStatusViewModel.isServerUp == false ? Color.red : Color.gray))
                        .frame(width: 10, height: 10)

                    Text(serverStatusViewModel.isServerUp == true ? "Server is Up" : (serverStatusViewModel.isServerUp == false ? "Server is Down, click (i) icon" : "Checking..."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

                List {
                    Section(header: Text("Today")) {
                        ForEach(todayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat, serverStatusViewModel: serverStatusViewModel), tag: chat, selection: $navigateToChat) {
                                Text(chat.title)
                            }
                        }
                        .onDelete { offsets in
                            deleteChat(at: offsets, from: todayChats)
                        }
                    }

                    Section(header: Text("7 Days")) {
                        ForEach(sevenDayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat, serverStatusViewModel: serverStatusViewModel)) {
                                Text(chat.title)
                            }
                        }
                        .onDelete { offsets in
                            deleteChat(at: offsets, from: sevenDayChats)
                        }
                    }

                    Section(header: Text("30 Days")) {
                        ForEach(thirtyDayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat, serverStatusViewModel: serverStatusViewModel)) {
                                Text(chat.title)
                            }
                        }
                        .onDelete { offsets in
                            deleteChat(at: offsets, from: thirtyDayChats)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingMoreOptions) {
            MoreOptionsView()
                .presentationDetents([.fraction(0.5)])
        }
    }

    private func deleteChat(at offsets: IndexSet, from filtered: [Chat]) {
        for offset in offsets {
            let chat = filtered[offset]
            if let indexInStore = chatStore.chats.firstIndex(where: { $0.id == chat.id }) {
                chatStore.chats.remove(at: indexInStore)
            }
        }
        chatStore.saveChatsToUserDefaults()
    }

    private var todayChats: [Chat] {
        chatStore.chats.filter { $0.createdDate.daysAgo() == 0 }
    }

    private var sevenDayChats: [Chat] {
        chatStore.chats.filter {
            let days = $0.createdDate.daysAgo()
            return days >= 1 && days < 7
        }
    }

    private var thirtyDayChats: [Chat] {
        chatStore.chats.filter {
            let days = $0.createdDate.daysAgo()
            return days >= 7 && days < 30
        }
    }
}

#Preview {
    ChatListView()
}
