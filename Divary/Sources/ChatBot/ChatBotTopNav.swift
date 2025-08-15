//
//  ChatBotTopNav.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//
import SwiftUI

struct ChatBotTopNav: View {
    let currentRoomName: String
    let currentChatRoomId: Int?
    let onMenuTap: () -> Void
    let onTitleEdit: ((String) -> Void)?
    
    @State private var showingTitleEdit = false
    @State private var editingTitle = ""
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image("chevron.left")
                    .foregroundStyle(Color.bw_black)
            }
            .padding(.top, 8)
            
            Spacer()
            
            Button(action: {
                if currentChatRoomId != nil, let onTitleEdit = onTitleEdit {
                    editingTitle = currentRoomName
                    showingTitleEdit = true
                }
            }) {
                Text(currentRoomName.isEmpty ? "챗봇" : currentRoomName)
                    .font(Font.omyu.regular(size: 20))
            }
            .disabled(currentChatRoomId == nil || onTitleEdit == nil)
            
            Spacer()
            
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .alert("채팅방 제목 변경", isPresented: $showingTitleEdit) {
            TextField("새 제목", text: $editingTitle)
            Button("취소", role: .cancel) { }
            Button("변경") {
                if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onTitleEdit?(editingTitle)
                }
            }
        } message: {
            Text("새로운 채팅방 제목을 입력해주세요.")
        }
    }
}
