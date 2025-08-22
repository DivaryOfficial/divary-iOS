//
//  AvatarResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

// 성공 응답 구조 (data 필드 포함)
struct AvatarApiSuccessResponse<T: Codable>: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let data: T
}

// 에러 응답 구조 (data 필드 없음)
struct AvatarApiErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let path: String
}

// 아바타 데이터 구조 (조회 응답)
struct AvatarResponseDTO: Codable {
    let name: String?
    let tank: String?
    let bodyColor: String?
    let bubbleText: String?
    let cheekColor: String?
    let speechBubble: String?
    let buddyPetInfo: BuddyPetInfoDTO?
    let mask: String?
    let pin: String?
    let regulator: String?
    let theme: String?
}

// 버디펫 정보 구조
struct BuddyPetInfoDTO: Codable {
    let budyPet: String?          
    let rotation: Double?
    let offset: Offset?
    
    private enum CodingKeys: String, CodingKey {
        case budyPet = "budyPet"   // 서버의 속성명과 매핑
        case rotation
        case offset
    }
}

struct Offset: Codable {
    let width: Double?
    let height: Double?
}

// MARK: - Avatar Request DTOs

// 아바타 저장 요청 구조 (서버로 전송)
struct AvatarRequestDTO: Codable {
    let name: String?
    let tank: String?
    let bodyColor: String
    let buddyPetInfo: BuddyPetInfoDTO?
    let bubbleText: String?
    let cheekColor: String?
    let speechBubble: String?
    let mask: String?
    let pin: String?
    let regulator: String?
    let theme: String
}
