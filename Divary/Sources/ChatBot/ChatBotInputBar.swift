//
//  ChatBotInputBar.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//


import SwiftUI

struct ChatInputBar: View {
    @Binding var messageText: String
    @Binding var showPhotoOptions: Bool
    let onSendMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: {
                    showPhotoOptions.toggle()
                }) {
                    Image(systemName: showPhotoOptions ? "xmark" : "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.primary)
                }
                
                TextField("무엇이든 물어보세요", text: $messageText, axis: .vertical)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.grayscale_g100)
                    .foregroundStyle(Color.bw_black)
                    .cornerRadius(8)
                    .lineLimit(1...4)
                
                Button(action: {
                    onSendMessage()
                }) {
                    Image("Chatsend")
                        .frame(width: 24, height: 24)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            if showPhotoOptions {
                HStack {
                    PhotoSelectionView()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ChatInputBar(
        messageText: .constant(""),
        showPhotoOptions: .constant(false),
        onSendMessage: {
            print("메시지 전송")
        }
    )
}
