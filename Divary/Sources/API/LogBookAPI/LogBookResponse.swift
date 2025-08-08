//
//  LogBookResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

struct LogListResponseDTO: Codable {
    let logs: [LogItemDTO]
}

struct LogItemDTO: Codable {
    let id: Int
    let iconType: String
    let name: String
    let date: String
}

struct LogDetailResponseDTO: Codable {
    let id: Int
    let date: String
    let saveStatus: String
    let place: String?
    let divePoint: String?
    let diveMethod: String?
    let divePurpose: String?
    let companions: [CompanionDTO]?
    let suitType: String?
    let equipment: String?
    let weight: Int?
    let perceivedWeight: String?
    let weather: String?
    let wind: String?
    let tide: String?
    let wave: String?
    let temperature: Int?
    let waterTemperature: Int?
    let perceivedTemp: String?
    let sight: String?
    let diveTime: Int?
    let maxDepth: Int?
    let avgDepth: Int?
    let decompressDepth: Int?
    let decompressTime: Int?
    let startPressure: Int?
    let finishPressure: Int?
    let consumption: Int?
}

struct CompanionDTO: Codable {
    let name: String
    let type: String
}

struct LogUpdateRequestDTO: Codable {
    let date: String
    let saveStatus: String
    let place: String?
    let divePoint: String?
    let diveMethod: String?
    let divePurpose: String?
    let companions: [CompanionDTO]?
    let suitType: String?
    let equipment: String?
    let weight: Int?
    let perceivedWeight: String?
    let weather: String?
    let wind: String?
    let tide: String?
    let wave: String?
    let temperature: Int?
    let waterTemperature: Int?
    let perceivedTemp: String?
    let sight: String?
    let diveTime: Int?
    let maxDepth: Int?
    let avgDepth: Int?
    let decompressDepth: Int?
    let decompressTime: Int?
    let startPressure: Int?
    let finishPressure: Int?
    let consumption: Int?
}

struct LogExistsResponseDTO: Codable {
    let exists: Bool
}
