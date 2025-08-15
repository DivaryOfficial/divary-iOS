
//
//  ChatHistoryView.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

import SwiftUI

struct ChatHistoryView: View {
    @Binding var showingHistoryList: Bool
    @State private var searchText = ""
    @State private var chatRooms: [ChatRoom] = []
    @State private var isLoading = true
    let onRoomSelected: (ChatRoom) -> Void  // ChatRoom 객체를 전달하도록 변경
    
    private let chatService = ChatService()
    
    private var filteredRooms: [ChatRoom] {
        if searchText.isEmpty {
            return chatRooms
        } else {
            return chatRooms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (기존과 동일)
            HStack {
                Spacer()
                Button(action: {
                    showingHistoryList = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            // Search Bar (기존과 동일)
            HStack {
                TextField("채팅 기록을 검색해보세요", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.bw_black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Chat Room List
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredRooms) { room in
                            ChatRoomRowView(
                                room: room,
                                onTap: {
                                    onRoomSelected(room)  // ChatRoom 객체 전달
                                },
                                onDelete: {
                                    deleteChatRoom(room)
                                }
                            )
                            
                            if room.id != filteredRooms.last?.id {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .onAppear {
            loadChatRooms()
        }
    }
    
    private func loadChatRooms() {
        chatService.getChatRooms { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let chatRoomDTOs):
                    self.chatRooms = chatRoomDTOs.map { ChatRoom(from: $0) }
                    
                case .failure(let error):
                    print("채팅방 목록 로드 실패: \(error)")
                    // 에러 발생시 Mock 데이터 사용
                    self.chatRooms = MockData.chatRooms
                }
            }
        }
    }
    
    private func deleteChatRoom(_ room: ChatRoom) {
        guard let apiId = room.apiId else {
            // Mock 데이터인 경우 로컬에서만 삭제
            chatRooms.removeAll { $0.id == room.id }
            return
        }
        
        // API 호출로 삭제
        chatService.deleteChatRoom(chatRoomId: apiId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    chatRooms.removeAll { $0.id == room.id }
                    
                case .failure(let error):
                    print("채팅방 삭제 실패: \(error)")
                    // 에러 처리 필요시 여기에 추가
                }
            }
        }
    }
}
