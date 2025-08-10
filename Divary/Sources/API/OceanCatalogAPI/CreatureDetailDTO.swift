//
//  CreatureDetailDTO.swift
//  Divary
//
//  Created by 김나영 on 8/10/25.
//

import Foundation

struct CreatureDetailDTO: DTO, Codable {
    let id: Int
    let name: String
    let type: String
    let size: String
    let appearPeriod: String
    let place: String
    let imageUrls: [String]?
    let appearance: AppearanceDTO
    let personality: PersonalityDTO
    let significant: SignificantDTO
}

struct AppearanceDTO: Codable {
    let body: String
    let colorCodes: [String]
    let color: String
    let pattern: String
    let etc: String
}

struct PersonalityDTO: Codable {
    let activity: String
    let socialSkill: String
    let behavior: String
    let reactivity: String
}

struct SignificantDTO: Codable {
    let toxicity: String
    let strategy: String
    let observeTip: String
    let otherFeature: String
}

// DTO -> Domain
extension CreatureDetailDTO {
    var entity: SeaCreatureDetail {
        SeaCreatureDetail(
            id: id,
            name: name,
            type: type,
            size: size,
            appearPeriod: appearPeriod,
            place: place,
            imageUrls: (imageUrls ?? []).compactMap { URL(string: $0) },
            appearance: Appearance(
                body: appearance.body,
                colorCodes: appearance.colorCodes,
                color: appearance.color,
                pattern: appearance.pattern,
                etc: appearance.etc
            ),
            personality: Personality(
                activity: personality.activity,
                socialSkill: personality.socialSkill,
                behavior: personality.behavior,
                reactivity: personality.reactivity
            ),
            significant: Significant(
                toxicity: significant.toxicity,
                strategy: significant.strategy,
                observeTip: significant.observeTip,
                otherFeature: significant.otherFeature
            )
        )
    }

    init(entity: SeaCreatureDetail) {
        self.id = entity.id
        self.name = entity.name
        self.type = entity.type
        self.size = entity.size
        self.appearPeriod = entity.appearPeriod
        self.place = entity.place
        self.imageUrls = entity.imageUrls.map { $0.absoluteString }
        self.appearance = AppearanceDTO(
            body: entity.appearance.body,
            colorCodes: entity.appearance.colorCodes,
            color: entity.appearance.color,
            pattern: entity.appearance.pattern,
            etc: entity.appearance.etc
        )
        self.personality = PersonalityDTO(
            activity: entity.personality.activity,
            socialSkill: entity.personality.socialSkill,
            behavior: entity.personality.behavior,
            reactivity: entity.personality.reactivity
        )
        self.significant = SignificantDTO(
            toxicity: entity.significant.toxicity,
            strategy: entity.significant.strategy,
            observeTip: entity.significant.observeTip,
            otherFeature: entity.significant.otherFeature
        )
    }
}
