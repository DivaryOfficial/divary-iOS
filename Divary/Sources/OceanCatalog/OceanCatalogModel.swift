//
//  OceanCatalogModel.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import Foundation

struct SeaCreatureCard: Decodable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let imageUrl: URL
}

extension SeaCreatureCard {
    var nameImageAssetName: String {
        switch name {
        case "흰동가리": return "clownfish"
        case "갯민숭달팽이": return "longhornCowfish"
        case "문어": return "octopus"
        case "청줄놀래기": return "anchovy"
        case "쏨뱅이": return "seaSlug"
        case "군소": return "turtle"
        case "복어": return "blowfish"
        case "돌돔": return "dolphin"
        case "나비고기": return "butterflyfish"
        case "보름달물해파리": return "combJelly"
        case "줄전갱이": return "shrimp"
        case "꼬덕새우": return "crab"
        case "바다거북": return "lionfish"
        case "불가사리": return "squid"
        case "쏠배감펭": return "clam"
        case "성게": return "starfish"
        default: return "placeholder"
        }
    }
}



// MARK: - Root Response
struct SeaCreatureResponse: Decodable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let data: SeaCreatureDetail
}

// MARK: - Main Data Model
struct SeaCreatureDetail: Decodable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let size: String
    let appearPeriod: String
    let place: String
    let imageUrls: [URL]
    let appearance: Appearance
    let personality: Personality
    let significant: Significant
}

// MARK: - Appearance
struct Appearance: Decodable {
    let body: String
    let colorCodes: [String]
    let color: String
    let pattern: String
    let etc: String
}

// MARK: - Personality
struct Personality: Decodable {
    let activity: String
    let socialSkill: String
    let behavior: String
    let reactivity: String
}

// MARK: - Significant Traits
struct Significant: Decodable {
    let toxicity: String
    let strategy: String
    let observeTip: String
    let otherFeature: String
}
