//
//  ChatMock.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//

import Foundation

struct MockData {
    
    // MARK: - Chat Rooms
    static let chatRooms: [ChatRoom] = [
        ChatRoom(name: "바다거북 질문"),
        ChatRoom(name: "클라운 피쉬 특징"),
        ChatRoom(name: "산호초 생태계"),
        ChatRoom(name: "해파리 종류"),
        ChatRoom(name: "고래 습성"),
        ChatRoom(name: "상어 정보"),
        ChatRoom(name: "바다 플랑크톤"),
        ChatRoom(name: "해조류 종류")
    ]
    
    // MARK: - Chat Messages
    static func getMessagesForRoom(_ roomName: String) -> [ChatMessage] {
        switch roomName {
        case "바다거북 질문":
            return [
                ChatMessage(content: "안녕하세요!\n궁금한 바다 생물의 특징을\n말해주시거나 사진을 올려주세요.\n어떤 생물인지 찾아드릴게요!", isUser: false),
                ChatMessage(content: "바다거북에 대해 알려주세요", isUser: true),
                ChatMessage(content: "바다거북은 바다에서 생활하는 파충류로, 등딱지가 있어 보호받습니다. 수명이 매우 길고, 바다와 육지를 오가며 생활해요!", isUser: false)
            ]
        case "클라운 피쉬 특징":
            return [
                ChatMessage(content: "안녕하세요!\n궁금한 바다 생물의 특징을\n말해주시거나 사진을 올려주세요.\n어떤 생물인지 찾아드릴게요!", isUser: false),
                ChatMessage(content: "클라운 피쉬는 어떤 특징이 있나요?", isUser: true),
                ChatMessage(content: "클라운 피쉬는 주황색 몸에 흰 줄무늬가 특징이에요! 말미잘과 공생관계를 맺고 살아갑니다.", isUser: false)
            ]
        default:
            return [
                ChatMessage(content: "안녕하세요!\n궁금한 바다 생물의 특징을\n말해주시거나 사진을 올려주세요.\n어떤 생물인지 찾아드릴게요!", isUser: false)
            ]
        }
    }
}
