//
//  LogBookResponse.swift
//  Divary
//
//  Updated by
//

import Foundation

// MARK: - 공통 API 응답 래퍼
struct APIResponse<T: Codable>: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let data: T
}

// MARK: - 로그 리스트 조회 응답
struct LogListResponseDTO: Codable {
    let name: String
    let date: String
    let iconType: String
    let saveStatus: String
    let logBaseInfoId: Int
}

// MARK: - 로그 생성 응답
struct LogCreateResponseDTO: Codable {
    let name: String
    let date: String
    let iconType: String
    let accumulation: Int?
    let logBaseInfoId: Int
}

// MARK: - 빈 로그북 생성/수정 응답 공통
struct EmptyLogCreateResponseDTO: Codable {
    let logBookId: Int
    let message: String
}

// MARK: - 동행자 정보 (응답)
/// 상세조회 응답에서는 key가 `companion`
struct CompanionResponseDTO: Codable {
    let companion: String?
    let type: String // 서버 ENUM 문자열 (LEADER/BUDDY/COMPANION)
}

// MARK: - 동행자 정보 (요청)
/// 수정/생성 요청에서는 key가 `name`
struct CompanionRequestDTO: Codable {
    let name: String
    let type: String // 서버 ENUM 문자열 (LEADER/BUDDY/COMPANION)
}

// MARK: - 로그베이스 상세 조회 응답 (로그북들 포함)
struct LogBaseDetailDTO: Codable {
    // 로그베이스 공통 정보
    let name: String
    let icon: String
    let date: String
    let accumulation: Int

    // 개별 로그북 정보
    let logBookId: Int
    let saveStatus: String? // null 가능

    // 다이빙 세부 정보
    let place: String?
    let divePoint: String?
    let diveMethod: String?
    let divePurpose: String?
    let companions: [CompanionResponseDTO]?
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

// MARK: - 로그북 수정 요청
struct LogUpdateRequestDTO: Codable {
    let date: String
    let saveStatus: String
    let place: String?
    let divePoint: String?
    let diveMethod: String?
    let divePurpose: String?
    let companions: [CompanionRequestDTO]? // ← name 키 사용
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

// MARK: - 로그 존재 확인 응답
struct LogExistsResponseDTO: Codable {
    let exists: Bool
    let logBaseInfoId: Int?
}
