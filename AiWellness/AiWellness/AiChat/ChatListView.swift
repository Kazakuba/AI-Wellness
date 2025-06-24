//
//  ChatListView.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import SwiftUI
import ConfettiSwiftUI

struct ChatListView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @ObservedObject var chatStore = ChatStore.shared
    @State private var isShowingMoreOptions = false
    @StateObject private var serverStatusViewModel = ServerStatusViewModel()
    @State private var isShowingAlert = false
    @StateObject private var confettiManager = ConfettiManager.shared
    @State private var path = NavigationPath()

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.indigo, Color.black] :
                                [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
                              ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                header

                Button(action: {
                    let newChat = chatStore.createNewChat(title: "New Chat")
                    path.append(newChat)
                }) {
                    Text("Create New Chats")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                serverStatus

                List {
                    Section(header: Text("Today").foregroundColor(.white.opacity(0.7))) {
                        ForEach(todayChats) { chat in
                            NavigationLink(value: chat) {
                                Text(chat.title)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            .listRowBackground(Color.white.opacity(0.15))
                        }
                        .onDelete { deleteChat(at: $0, from: todayChats) }
                    }

                    Section(header: Text("7 DAYS").foregroundColor(.white.opacity(0.7))) {
                        ForEach(sevenDayChats) { chat in
                            NavigationLink(value: chat) {
                                Text(chat.title)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            .listRowBackground(Color.white.opacity(0.15))
                        }
                        .onDelete { deleteChat(at: $0, from: sevenDayChats) }
                    }

                    Section(header: Text("30 DAYS").foregroundColor(.white.opacity(0.7))) {
                        ForEach(thirtyDayChats) { chat in
                            NavigationLink(value: chat) {
                                Text(chat.title)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            .listRowBackground(Color.white.opacity(0.15))
                        }
                        .onDelete { deleteChat(at: $0, from: thirtyDayChats) }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .foregroundColor(.white)
                // ✅ FADE-OUT MASK TO HIDE CONTENT BEHIND THE TAB BAR
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.9), // Adjust this value (e.g., 0.85) to control where the fade starts
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .background(gradient.ignoresSafeArea())
            .navigationBarHidden(true)
            .confettiCannon(trigger: $confettiManager.trigger, num: 40, confettis: confettiManager.confettis, colors: [.yellow, .green, .blue, .orange])
            .navigationDestination(for: Chat.self) { chat in
                ChatDetailView(chat: chat, serverStatusViewModel: serverStatusViewModel)
            }
        }

        .background(Color.clear)
        .sheet(isPresented: $isShowingMoreOptions) {
            MoreOptionsView()
                .presentationDetents([.fraction(0.5)])
        }
    }

    private var header: some View {
        HStack {
            Button(action: { isShowingAlert = true }) {
                Image(systemName: "info.circle")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
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
                .foregroundColor(isDarkMode ? .white : .black)

            Spacer()

            Button(action: {
                isShowingMoreOptions.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .padding()
    }

    private var serverStatus: some View {
        HStack {
            Text("Chats History")
                .font(.title2)
                .bold()
                .foregroundColor(isDarkMode ? .white : .black)

            Spacer()

            Circle()
                .fill(serverStatusViewModel.isServerUp == true ? Color.green : (serverStatusViewModel.isServerUp == false ? Color.red : Color.gray))
                .frame(width: 10, height: 10)

            Text(serverStatusViewModel.isServerUp == true ? "Server is Up" : (serverStatusViewModel.isServerUp == false ? "Server is Down" : "Checking..."))
                .font(.caption)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.trailing, 20)
        }
        .padding(.leading)
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
        chatStore.chats.filter { Calendar.current.isDateInToday($0.createdDate) }
    }

    private var sevenDayChats: [Chat] {
        chatStore.chats.filter {
            !Calendar.current.isDateInToday($0.createdDate) && $0.createdDate.daysAgo() < 7
        }
    }

    private var thirtyDayChats: [Chat] {
        chatStore.chats.filter {
            let days = $0.createdDate.daysAgo()
            return days >= 7 && days < 30
        }
    }

    private func handleChatAchievement() {
        ConfettiManager.shared.celebrate()
    }
}

#Preview {
    TabView {
        ChatListView()
            .tabItem {
                Label("AI Chat", systemImage: "message")
            }
    }
}
