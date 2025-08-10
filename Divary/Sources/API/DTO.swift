//
//  DTO.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation

protocol DTO: Codable {
    associatedtype EntityType: Entity
    var entity: EntityType { get }
    init(entity: EntityType)
}
