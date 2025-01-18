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
    @State private var isShowingNewChatSheet = false
    @State private var isShowingMoreOptions = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // handle hamburger menu
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.headline)
                            .foregroundColor(.white)
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
                    isShowingNewChatSheet = true
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

                Text("Chats History")
                    .font(.title2)
                    .bold()
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                List {
                    Section(header: Text("Today")) {
                        ForEach(todayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
                                Text(chat.title)
                            }
                        }
                        .onDelete { offsets in
                            deleteChat(at: offsets, from: todayChats)
                        }
                    }

                    Section(header: Text("7 Days")) {
                        ForEach(sevenDayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
                                Text(chat.title)
                            }
                        }
                        .onDelete { offsets in
                            deleteChat(at: offsets, from: sevenDayChats)
                        }
                    }

                    Section(header: Text("30 Days")) {
                        ForEach(thirtyDayChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
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
                    .sheet(isPresented: $isShowingNewChatSheet) {
                        CreateNewChatView()
                    }
                    .sheet(isPresented: $isShowingMoreOptions) {
                        MoreOptionsView()
                            .presentationDetents([.fraction(0.5)])
                    }
                }

    private func deleteChat(at offsets: IndexSet, from filtered: [Chat]) {
        for offset in offsets {
            let chat = filtered[offset]
            // Find the same chat in the main store array by ID
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
