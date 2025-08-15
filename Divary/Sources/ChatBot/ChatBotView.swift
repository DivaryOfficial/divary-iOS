import SwiftUI
import Foundation

struct ChatBotView: View {
    @State private var messageText = ""
    @State private var showPhotoOptions = false
    @State private var showingHistoryList = false
    @State private var messages: [ChatMessage] = []
    @State private var currentRoomName = "새 채팅"
    @State private var currentChatRoomId: Int? = nil
    @State private var isLoading = false
    
    private let chatService = ChatService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation
            ChatBotTopNav(
                currentRoomName: currentRoomName,
                currentChatRoomId: currentChatRoomId,
                onMenuTap: {
                    showingHistoryList = true
                },
                onTitleEdit: { newTitle in
                    updateChatRoomTitle(newTitle)
                }
            )
            
            // Messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        // 초기 메시지
                        MessageBubbleView(message: ChatMessage(
                            content: "안녕하세요!\n궁금한 바다 생물의 특징을\n말해주시거나 사진을 올려주세요.\n어떤 생물인지 찾아드릴게요!",
                            isUser: false
                        ))
                    }
                    
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("응답 중...")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
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
                        
                        ChatHistoryView(showingHistoryList: $showingHistoryList) { chatRoom in
                            loadChatRoom(chatRoom)
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
        
        let messageToSend = messageText
        messageText = ""
        showPhotoOptions = false
        isLoading = true
        
        // API 호출
        chatService.sendMessage(
            chatRoomId: currentChatRoomId,
            message: messageToSend,
            image: nil
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    // 현재 채팅방 ID 업데이트
                    currentChatRoomId = response.chatRoomId
                    currentRoomName = response.title
                    
                    // 새로운 메시지들 추가 (AI 응답)
                    let newMessages = response.newMessages.compactMap { messageDTO in
                        // 사용자 메시지는 이미 추가했으므로 AI 응답만 추가
                        messageDTO.role != "user" ? ChatMessage(from: messageDTO) : nil
                    }
                    messages.append(contentsOf: newMessages)
                    
                case .failure(let error):
                    print("메시지 전송 실패: \(error)")
                    // 에러 처리 - 간단한 에러 메시지 표시
                    let errorMessage = ChatMessage(
                        content: "죄송해요, 잠시 문제가 발생했어요. 다시 시도해주세요.",
                        isUser: false
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
    
    private func loadChatRoom(_ chatRoom: ChatRoom) {
        guard let apiId = chatRoom.apiId else {
            // Mock 데이터인 경우
            currentRoomName = chatRoom.name
            messages = MockData.getMessagesForRoom(chatRoom.name)
            showingHistoryList = false
            return
        }
        
        // API에서 채팅방 상세 정보 로드
        chatService.getChatRoomDetail(chatRoomId: apiId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    currentChatRoomId = response.chatRoom.id
                    currentRoomName = response.chatRoom.title
                    messages = response.messages.map { ChatMessage(from: $0) }
                    
                case .failure(let error):
                    print("채팅방 로드 실패: \(error)")
                    // 에러 발생시 빈 채팅방으로 처리
                    currentRoomName = chatRoom.name
                    messages = []
                }
                showingHistoryList = false
            }
        }
    }
    
    // 그리고 새로운 메서드 추가:
    private func updateChatRoomTitle(_ newTitle: String) {
        guard let chatRoomId = currentChatRoomId else { return }
        
        chatService.updateChatRoomTitle(chatRoomId: chatRoomId, title: newTitle) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    currentRoomName = newTitle
                    print("채팅방 제목이 변경되었습니다: \(newTitle)")
                    
                case .failure(let error):
                    print("제목 변경 실패: \(error)")
                }
            }
        }
    }
}
