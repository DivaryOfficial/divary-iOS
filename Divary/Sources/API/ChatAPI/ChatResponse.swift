//
//  ChatResponse.swift
//  Divary
//
//  Created by 바견규 on 8/15/25.
//

import Foundation

// MARK: - Base Response
struct ChatBaseResponseDTO<T: Codable>: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let path: String?  // Optional로 변경
    let data: T
}

// MARK: - Send Message Response
struct SendMessageResponseDTO: Codable {
    let chatRoomId: Int
    let title: String
    let newMessages: [MessageDTO]
    let usage: UsageDTO
}

// MARK: - Chat Room List Response
typealias ChatRoomListResponseDTO = [ChatRoomDTO]

// MARK: - Chat Room Detail Response
struct ChatRoomDetailResponseDTO: Codable {
    let chatRoom: ChatRoomDTO
    let messages: [MessageDTO]
    let usage: UsageDTO
}

// MARK: - Delete Chat Room Response
struct DeleteChatRoomResponseDTO: Codable {
    // Empty object for successful deletion
}

// MARK: - Error Response
struct ChatErrorResponseDTO: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let path: String?  // Optional로 변경
}

// MARK: - Supporting Models
struct ChatRoomDTO: Codable {
    let id: Int
    let title: String
    let messageCount: Int
    let createdAt: String
    let updatedAt: String
}

struct MessageDTO: Codable {
    let id: String
    let role: String
    let content: String
    let timestamp: String
    let attachments: [AttachmentDTO]?
}

struct AttachmentDTO: Codable {
    let id: Int
    let fileUrl: String
    let originalFilename: String
}

struct UsageDTO: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let model: String
    let cost: Double
}
