//
//  NotificationResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

struct NotificationListResponseDTO: Codable {
    let notifications: [NotificationItemDTO]
}

struct NotificationItemDTO: Codable {
    let id: Int
    let title: String
    let content: String
    let isRead: Bool
    let createdAt: String
}
