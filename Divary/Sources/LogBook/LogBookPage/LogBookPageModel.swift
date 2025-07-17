//
//  LogBookPage.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

// 섹션이 작성 중인지 모두 채웠는지 확인
enum SectionStatus {
    case empty       // 회색
    case partial     // 작성중 (태그 표시)
    case complete    // 진한 색
}

struct DiveLogData: Decodable {
    let overview: DiveOverview?           // 다이빙 개요
    let participants: DiveParticipants?   // 동행자 정보
    let equipment: DiveEquipment?         // 장비 정보
    let environment: DiveEnvironment?    // 환경 정보
    let profile: DiveProfile?             // 다이빙 프로파일
}

// DiveLogPage가 빈 페이지인지 확인
extension DiveLogData {
    var isEmpty: Bool {
        overview == nil &&
        participants == nil &&
        equipment == nil &&
        environment == nil &&
        profile == nil
    }
}

struct DiveOverview: Decodable {
    let title: String?   // 다이빙 제목
    let point: String?   // 다이빙 포인트
    let purpose: String? // 다이빙 목적
    let method: String?  // 다이빙 방식 (예: 보트, 비치 등)
}

struct DiveParticipants: Decodable {
    let leader: String?     // 리더 이름
    let buddy: String?      // 버디 이름
    let companion: [String]?     // 동행자 이름
}

struct DiveEquipment: Decodable {
    let suitType: String?   // 슈트 종류 (예: 드라이, 웻슈트 등)
    let Equipment: [String]?
    let weight: Int?     // 웨이트 무게 (kg 단위)
}

struct DiveEnvironment: Decodable {
    let weather: String?    // 날씨
    let wind: String?       // 바람 상태
    let current: String?    // 조류 상태 (예: 약함, 강함 등)
    let wave: String?       // 파도 상태
    let airTemp: Int?    // 기온 (°C)
    let waterTemp: Int?  // 수온 (°C)
    let visibility: String? // 시야 (예: 10m 등)
}

struct DiveProfile: Decodable {
    let diveTime: Int?        // 다이빙 시간 (분)
    let maxDepth: Int?     // 최대 수심 (m)
    let avgDepth: Int?     // 평균 수심 (m)
    let decoStop: Int?     // 감압 정지 시간 (분)
    let startPressure: Int?   // 시작 탱크 압력 (bar)
    let endPressure: Int?     // 종료 탱크 압력 (bar)
}



