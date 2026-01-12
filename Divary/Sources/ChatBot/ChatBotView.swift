import SwiftUI
import Foundation
import Combine

struct ChatBotView: View {
    @State private var messageText = ""
    @State private var showPhotoOptions = false
    @State private var showingHistoryList = false
    @State private var messages: [ChatMessage] = []
    @State private var currentRoomName = "챗봇"
    @State private var currentChatRoomId: Int? = nil
    @State private var isLoading = false
    @State private var selectedImage: UIImage? = nil
    @State private var cancellables = Set<AnyCancellable>()
    
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
                                .foregroundStyle(.gray)
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
                selectedImage: $selectedImage,
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
        let hasText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = selectedImage != nil
        
        guard hasText || hasImage else { return }
        
        // 사용자 메시지를 화면에 추가
        let userMessage = ChatMessage(
            content: hasText ? messageText : "이미지를 보냈습니다.",
            isUser: true,
            image: selectedImage?.pngData()
        )
        messages.append(userMessage)
        
        let messageToSend = messageText
        let imageToSend = selectedImage
        
        // UI 초기화
        messageText = ""
        selectedImage = nil
        showPhotoOptions = false
        isLoading = true
        
        // 이미지 바이너리 데이터 준비 후 바로 메시지 전송
        let imageData = imageToSend?.jpegData(compressionQuality: 0.8)
        sendTextMessage(messageToSend, imageData: imageData)
    }
    
    private func sendTextMessage(_ message: String, imageData: Data?) {
        DebugLogger.log("전송할 메시지: '\(message)'")
        DebugLogger.log("이미지 데이터: \(imageData?.count ?? 0) bytes")
        
        chatService.sendMessage(
            chatRoomId: currentChatRoomId,
            message: message.isEmpty ? "이미지를 보냈습니다." : message,
            imageData: imageData
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
                    handleSendError("메시지 전송 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleSendError(_ errorMessage: String) {
        DispatchQueue.main.async {
            isLoading = false
            DebugLogger.error(errorMessage)
            
            // 에러 메시지 표시
            let errorMsg = ChatMessage(
                content: "죄송해요, 잠시 문제가 발생했어요. 다시 시도해주세요.",
                isUser: false
            )
            messages.append(errorMsg)
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
                    DebugLogger.error("채팅방 로드 실패: \(error)")
                    // 에러 발생시 빈 채팅방으로 처리
                    currentRoomName = chatRoom.name
                    messages = []
                }
                showingHistoryList = false
            }
        }
    }
    
    private func updateChatRoomTitle(_ newTitle: String) {
        guard let chatRoomId = currentChatRoomId else { return }
        
        chatService.updateChatRoomTitle(chatRoomId: chatRoomId, title: newTitle) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    currentRoomName = newTitle
                    DebugLogger.success("채팅방 제목이 변경되었습니다: \(newTitle)")
                    
                case .failure(let error):
                    DebugLogger.error("제목 변경 실패: \(error)")
                }
            }
        }
    }
}
