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
    let imageUrl: URL?
}

// MARK: - 해양도감 탭바 카테고리
enum SeaCreatureCategory: String, CaseIterable, Identifiable {
    case all = "전체"
    case fish = "어류"
    case crustacean = "갑각류"
    case mollusk = "연체동물"
    case other = "기타"

    var id: String { self.rawValue }
}

// MARK: - Main Data Model
struct SeaCreatureDetail: Codable, Identifiable, Equatable, Entity, Hashable {
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

extension SeaCreatureDetail {
    static func fromEntity(_ e: CreatureCardEntity) -> SeaCreatureDetail {
        SeaCreatureDetail(
            id: e.id,
            name: e.name,
            type: e.type,
            size: "-", appearPeriod: "-", place: "-",
            imageUrls: e.dogamProfileUrl != nil ? [e.dogamProfileUrl!] : [],
            appearance: Appearance(body: "-", colorCodes: [], color: "-", pattern: "-", etc: "-"),
            personality: Personality(activity: "-", socialSkill: "-", behavior: "-", reactivity: "-"),
            significant: Significant(toxicity: "-", strategy: "-", observeTip: "-", otherFeature: "-")
        )
    }
}

// MARK: - Appearance
struct Appearance: Equatable, Entity, Hashable {
    let body: String
    let colorCodes: [String]
    let color: String
    let pattern: String
    let etc: String
}

// MARK: - Personality
struct Personality: Equatable, Entity, Hashable {
    let activity: String
    let socialSkill: String
    let behavior: String
    let reactivity: String
}

// MARK: - Significant Traits
struct Significant: Equatable, Entity, Hashable {
    let toxicity: String
    let strategy: String
    let observeTip: String
    let otherFeature: String
}
