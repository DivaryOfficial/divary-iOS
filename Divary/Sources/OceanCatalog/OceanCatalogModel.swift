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
