
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
    @State private var chatRooms = MockData.chatRooms
    let onRoomSelected: (String) -> Void
    
    private var filteredRooms: [ChatRoom] {
        if searchText.isEmpty {
            return chatRooms
        } else {
            return chatRooms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
//                Text("채팅방")
//                    .font(.title2)
//                    .fontWeight(.bold)
                
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
            
            // Search Bar
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
                }else{
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredRooms) { room in
                        
                        ChatRoomRowView(
                            room: room,
                            onTap: {
                                onRoomSelected(room.name)
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
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
    private func deleteChatRoom(_ room: ChatRoom) {
        chatRooms.removeAll { $0.id == room.id }
    }
}

struct ChatRoomRowView: View {
    let room: ChatRoom
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var showingDeleteMenu = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 MM월 dd일"
        return formatter.string(from: room.createdAt)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    
                    // Chat Icon
                    VStack(alignment: .leading, spacing: 2) {
                        
                        HStack{
                            Text(room.name)
                                .font(Font.omyu.regular(size: 16))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            // More button
                            Button(action: {
                                showingDeleteMenu = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(width: 24, height: 24)
                            }
                            .actionSheet(isPresented: $showingDeleteMenu) {
                                ActionSheet(
                                    title: Text("채팅방 관리"),
                                    message: Text("이 채팅방을 삭제하시겠습니까?"),
                                    buttons: [
                                        .destructive(Text("삭제")) {
                                            onDelete()
                                        },
                                        .cancel(Text("취소"))
                                    ]
                                )
                            }
                        }
                        
                        HStack{
                            Spacer()
                            
                            Text(formattedDate)
                                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 10))
                                .foregroundColor(.grayscale_g400)
                        }
                       
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
      
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    ChatHistoryView(
        showingHistoryList: .constant(true),
        onRoomSelected: { roomName in
            print("선택된 채팅방: \(roomName)")
        }
    )
}
