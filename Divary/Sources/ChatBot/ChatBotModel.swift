//
//  ChatBotModel.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

import SwiftUI

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let image: Data?
    let timestamp: Date
    
    init(content: String, isUser: Bool, image: Data? = nil) {
        self.content = content
        self.isUser = isUser
        self.image = image
        self.timestamp = Date()
    }
}

// MARK: - Chat Room Model
struct ChatRoom: Identifiable {
    let id = UUID()
    let name: String
    let createdAt: Date
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}
