//
//  SeaCreatureCardDTO.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation

struct CreatureCardDTO: DTO {
    let id: Int?
    let name: String?
    let type: String?
    let dogamProfileUrl: String?
    
    init(id: Int?, name: String?, type: String?, dogamProfileUrl: String?) {
        self.id = id
        self.name = name
        self.type = type
        self.dogamProfileUrl = dogamProfileUrl
    }
    
    init(entity: CreatureCardEntity) {
        self.id = entity.id
        self.name = entity.name
        self.type = entity.type
        self.dogamProfileUrl = entity.dogamProfileUrl?.absoluteString
    }
    
    var entity: CreatureCardEntity {
        return CreatureCardEntity(
            id: id ?? 0,
            name: name ?? "",
            type: type ?? "",
            dogamProfileUrl: URL(string: dogamProfileUrl ?? "")
        )
    }
}

struct CreatureCardEntity: Entity {
    let id: Int
    let name: String
    let type: String
    let dogamProfileUrl: URL?
}
