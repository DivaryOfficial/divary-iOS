//
//  ChatBotModel.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

import SwiftUI

// 기존 ChatMessage 구조체를 API 응답에 맞게 확장
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let image: Data?
    let timestamp: Date
    
    // API 응답용 추가 프로퍼티
    let messageId: String?
    let attachments: [AttachmentDTO]?
    
    init(content: String, isUser: Bool, image: Data? = nil) {
        self.content = content
        self.isUser = isUser
        self.image = image
        self.timestamp = Date()
        self.messageId = nil
        self.attachments = nil
    }
    
    // API 응답으로부터 생성하는 이니셜라이저 추가
    init(from messageDTO: MessageDTO) {
        self.content = messageDTO.content
        self.isUser = messageDTO.role == "user"
        self.image = nil // 이미지는 필요시 별도 로드
        self.messageId = messageDTO.id
        self.attachments = messageDTO.attachments
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.timestamp = formatter.date(from: messageDTO.timestamp) ?? Date()
    }
}

// ChatRoom도 API 응답에 맞게 확장
struct ChatRoom: Identifiable {
    let id = UUID()
    let name: String
    let createdAt: Date
    
    // API 응답용 추가 프로퍼티
    let apiId: Int?
    let messageCount: Int
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.apiId = nil
        self.messageCount = 0
    }
    
    // API 응답으로부터 생성하는 이니셜라이저 추가
    init(from chatRoomDTO: ChatRoomDTO) {
        self.name = chatRoomDTO.title
        self.apiId = chatRoomDTO.id
        self.messageCount = chatRoomDTO.messageCount
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.createdAt = formatter.date(from: chatRoomDTO.createdAt) ?? Date()
    }
}
