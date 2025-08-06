//
//  SimpleChatBotView.swift
//  Divary
//
//  Created by User on 8/5/25.
//
//
import SwiftUI
import Foundation

struct ChatBotView: View {
    @State private var messageText = ""
    @State private var showPhotoOptions = false
    @State private var showingHistoryList = false
    @State private var messages: [ChatMessage] = MockData.getMessagesForRoom("default")
    @State private var currentRoomName = "새 채팅"
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation
            ChatBotTopNav(onMenuTap: {
                showingHistoryList = true
            })
            
            // Messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            
            // Input Area
            ChatInputBar(
                messageText: $messageText,
                showPhotoOptions: $showPhotoOptions,
                onSendMessage: sendMessage
            )
        }
        .onTapGesture {
            showPhotoOptions = false
        }
        .overlay(
            Group {
                if showingHistoryList {
                    HStack(spacing: 0) {
                        Spacer()
                            .background(Color.black.opacity(0.3))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showingHistoryList = false
                            }
                            .shadow(radius: 10)
                        
                        ChatHistoryView(showingHistoryList: $showingHistoryList) { roomName in
                            loadChatRoom(roomName)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                    }
                    .transition(.move(edge: .trailing))
                }
            }
        )
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(userMessage)
        
        messageText = ""
        showPhotoOptions = false
        
        // 봇 응답 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let responses = [
                "흥미로운 질문이네요! 바다 생물에 대해 더 자세히 알려드릴게요.",
                "바다는 정말 신비로운 곳이에요. 어떤 생물이 궁금하신가요?",
                "사진을 올려주시면 더 정확한 정보를 드릴 수 있어요!",
                "바다 생물의 세계는 정말 다양해요. 계속 질문해주세요!"
            ]
            
            let botResponse = responses.randomElement() ?? "죄송해요, 다시 한 번 말씀해주세요."
            let botMessage = ChatMessage(content: botResponse, isUser: false)
            messages.append(botMessage)
        }
    }
    
    private func loadChatRoom(_ roomName: String) {
        currentRoomName = roomName
        messages = MockData.getMessagesForRoom(roomName)
        showingHistoryList = false
    }
}

// MARK: - Preview
#Preview {
    ChatBotView()
}//
//  SimpleChatBotView.swift
//  Divary
//
//  Created by User on 8/5/25.
//
