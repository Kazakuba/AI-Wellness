//
//  ChatStore.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import SwiftUI
import FirebaseAuth

class ChatStore: ObservableObject {
    @Published var chats: [Chat] = []
    static let shared = ChatStore()

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private init() {
        // Start by loading for the current user (if any)
        loadChatsFromUserDefaults()

        // Observe changes in Firebase Auth
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if user == nil {
                // User signed out -> clear or load empty
                self.chats = []
            } else {
                // New user signed in -> reload from UserDefaults
                self.loadChatsFromUserDefaults()
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func loadChatsFromUserDefaults() {
        guard let user = Auth.auth().currentUser else {
            chats = []
            return
        }
        let uid = user.uid
        let key = "chats_\(uid)"

        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoded = try JSONDecoder().decode([Chat].self, from: data)
                self.chats = decoded
            } catch {
                print("Error decoding chats:", error)
                self.chats = []
            }
        } else {
            self.chats = []
        }
    }

    func saveChatsToUserDefaults() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        let key = "chats_\(uid)"

        do {
            let data = try JSONEncoder().encode(chats)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding chats:", error)
        }
    }

    func createNewChat(title: String) -> Chat {
        let newChat = Chat(title: title)
        //newChat.messages.append(Message(content: "Welcome to \(title)!", sender: "System"))
        chats.insert(newChat, at: 0)
        saveChatsToUserDefaults()
        return newChat
    }

    func addMessage(_ content: String, sender: String, to chatID: UUID) {
        guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
        chats[index].messages.append(Message(content: content, sender: sender))
        saveChatsToUserDefaults()
    }

    func sendMessageUsingAppleAI(content: String, sender: String, chatID: UUID) {
        // Add user message
        addMessage(content, sender: sender, to: chatID)

        // Simulate AI response using Natural Language framework or Core ML
        let aiResponse = "This is a simulated response from Apple's AI."

        // Add AI response
        addMessage(aiResponse, sender: "AppleAI", to: chatID)
    }

    func sendMessageUsingGeminiAPI(content: String, sender: String, chatID: UUID) {
        // Add user message
        addMessage(content, sender: sender, to: chatID)

        // Call Gemini API
        GeminiAPIService.shared.sendMessage(content, chatHistory: chats.first(where: { $0.id == chatID })?.messages ?? []) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let aiResponse):
                    // Add AI response
                    self?.addMessage(aiResponse, sender: "GeminiAI", to: chatID)
                case .failure(let error):
                    // Show error to the user
                    self?.showErrorToUser("Failed to get response from Gemini API: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showErrorToUser(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // Find the top-most view controller to present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {

            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
