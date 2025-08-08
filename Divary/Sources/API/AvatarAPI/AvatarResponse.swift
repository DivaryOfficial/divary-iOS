//
//  AvatarResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

struct AvatarResponseDTO: Codable {
    let name: String
    let tank: String
    let bodyColor: String
    let buddyPetInfo: BuddyPetInfoDTO
    let bubbleText: String
    let cheekColor: String
    let speechBubble: String
    let mask: String
    let pin: String
    let regulator: String
    let theme: String
}

struct BuddyPetInfoDTO: Codable {
    let budyPet: String
    let rotation: Double
    let scale: Double
}

struct AvatarRequestDTO: Codable {
    let name: String
    let tank: String
    let bodyColor: String
    let buddyPetInfo: BuddyPetInfoDTO
    let bubbleText: String
    let cheekColor: String
    let speechBubble: String
    let mask: String
    let pin: String
    let regulator: String
    let theme: String
}
