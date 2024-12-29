//
//  ChatView.swift
//  AiWellness
//
//  Created by Kazakuba on 29.12.24..
//


import SwiftUI
//Temp mock
struct AiChat: View {
    @State private var messages: [String] = ["Hello! How can I help you today?", "Hi! I have a question."]
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            // Chat Messages
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { message in
                        HStack {
                            if message.starts(with: "Hi") {
                                Spacer()
                                Text(message)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text(message)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            // Input Field and Send Button
            HStack {
                TextField("Type a message...", text: $inputText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    if !inputText.isEmpty {
                        messages.append(inputText)
                        inputText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        AiChat()
    }
}
