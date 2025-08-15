//
//  ChatRoomRowView.swift
//  Divary
//
//  Created by 바견규 on 8/15/25.
//

import SwiftUI

struct ChatRoomRowView: View {
    let room: ChatRoom
    let onTap: () -> Void
    let onDelete: () -> Void
    let onEdit: (String) -> Void
    @State private var showingDeleteMenu = false
    @State private var showingEditAlert = false
    @State private var editingTitle = ""
    
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
                            
                            // More button with context menu
                            Menu {
                                Button(action: {
                                    editingTitle = room.name
                                    showingEditAlert = true
                                }) {
                                    Label("이름 바꾸기", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    showingDeleteMenu = true
                                }) {
                                    Label("삭제하기", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(width: 24, height: 24)
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
        .alert("채팅방 이름 변경", isPresented: $showingEditAlert) {
            TextField("새 이름", text: $editingTitle)
            Button("취소", role: .cancel) { }
            Button("변경") {
                if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onEdit(editingTitle)
                }
            }
        } message: {
            Text("새로운 채팅방 이름을 입력해주세요.")
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
}

#Preview {
    ChatRoomRowView(
        room: ChatRoom(name: "바다거북 질문"),
        onTap: {
            print("채팅방 선택")
        },
        onDelete: {
            print("채팅방 삭제")
        },
        onEdit: { newTitle in
            print("제목 변경: \(newTitle)")
        }
    )
}
