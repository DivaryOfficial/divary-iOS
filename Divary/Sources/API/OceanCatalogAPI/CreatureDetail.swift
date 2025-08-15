//
//  CreatureDetailDTO.swift
//  Divary
//
//  Created by 김나영 on 8/10/25.
//

import Foundation

struct CreatureDetailDTO: DTO {
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
    
    // DTO → Entity
    var entity: SeaCreatureDetail {
        SeaCreatureDetail(
            id: id,
            name: name,
            type: type,
            size: size,
            appearPeriod: appearPeriod,
            place: place,
            imageUrls: (imageUrls ?? []).compactMap { URL(string: $0) },
            appearance: appearance.entity,
            personality: personality.entity,
            significant: significant.entity
        )
    }
    
    // Entity → DTO
    init(entity: SeaCreatureDetail) {
        self.id = entity.id
        self.name = entity.name
        self.type = entity.type
        self.size = entity.size
        self.appearPeriod = entity.appearPeriod
        self.place = entity.place
        self.imageUrls = entity.imageUrls.map { $0.absoluteString }
        self.appearance = AppearanceDTO(entity: entity.appearance)
        self.personality = PersonalityDTO(entity: entity.personality)
        self.significant = SignificantDTO(entity: entity.significant)
    }
}

struct AppearanceDTO: DTO {
    let body: String
    let colorCodes: [String]
    let color: String
    let pattern: String
    let etc: String
    
    var entity: Appearance {
        Appearance(body: body, colorCodes: colorCodes, color: color, pattern: pattern, etc: etc)
    }
    
    init(entity: Appearance) {
        self.body = entity.body
        self.colorCodes = entity.colorCodes
        self.color = entity.color
        self.pattern = entity.pattern
        self.etc = entity.etc
    }
}

struct PersonalityDTO: DTO {
    let activity: String
    let socialSkill: String
    let behavior: String
    let reactivity: String
    
    var entity: Personality {
        Personality(activity: activity, socialSkill: socialSkill, behavior: behavior, reactivity: reactivity)
    }
    
    init(entity: Personality) {
        self.activity = entity.activity
        self.socialSkill = entity.socialSkill
        self.behavior = entity.behavior
        self.reactivity = entity.reactivity
    }
}

struct SignificantDTO: DTO {
    let toxicity: String
    let strategy: String
    let observeTip: String
    let otherFeature: String
    
    var entity: Significant {
        Significant(toxicity: toxicity, strategy: strategy, observeTip: observeTip, otherFeature: otherFeature)
    }
    
    init(entity: Significant) {
        self.toxicity = entity.toxicity
        self.strategy = entity.strategy
        self.observeTip = entity.observeTip
        self.otherFeature = entity.otherFeature
    }
}
