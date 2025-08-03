//
//  LogBookPage.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import Foundation
import SwiftUI

//어떤 섹션을 선택했는지
enum InputSectionType: Int, Identifiable {
    case overview = 0
    case participants
    case equipment
    case environment
    case profile

    var id: Int { rawValue }
}

// 섹션이 작성 중인지 모두 채웠는지 확인
enum SectionStatus {
    case empty       // 회색
    case partial     // 작성중 (태그 표시)
    case complete    // 진한 색
}

@Observable
class DiveLogData {
    var title: String        // 로그 제목
    var date: String         // 로그 날짜 (예: "2022-01-23")
    
    var overview: DiveOverview?
    var participants: DiveParticipants?
    var equipment: DiveEquipment?
    var environment: DiveEnvironment?
    var profile: DiveProfile?

    init(
        title: String = "",
        date: String = "",
        overview: DiveOverview? = nil,
        participants: DiveParticipants? = nil,
        equipment: DiveEquipment? = nil,
        environment: DiveEnvironment? = nil,
        profile: DiveProfile? = nil
    ) {
        self.title = title
        self.date = date
        self.overview = overview
        self.participants = participants
        self.equipment = equipment
        self.environment = environment
        self.profile = profile
    }
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

@Observable
class DiveOverview {
    var title: String?   // 다이빙 제목
    var point: String?   // 다이빙 포인트
    var purpose: String? // 다이빙 목적
    var method: String?  // 다이빙 방식 (예: 보트, 비치 등)
    
    init(
        title: String? = nil,
        point: String? = nil,
        purpose: String? = nil,
        method: String? = nil
    ) {
        self.title = title
        self.point = point
        self.purpose = purpose
        self.method = method
    }
}

@Observable
class DiveParticipants {
    var leader: String?     // 리더 이름
    var buddy: String?      // 버디 이름
    var companion: [String]?     // 동행자 이름
    
    init(
        leader: String? = nil,
        buddy: String? = nil,
        companion: [String]? = nil
    ) {
        self.leader = leader
        self.buddy = buddy
        self.companion = companion
    }
}

@Observable
class DiveEquipment {
    var suitType: String?   // 슈트 종류 (예: 드라이, 웻슈트 등)
    var Equipment: [String]?
    var weight: Int?     // 웨이트 무게 (kg 단위)
    var pweight: String? // 체감 무게
    
    
    init(
        suitType: String? = nil,
        Equipment: [String]? = nil,
        weight: Int? = nil,
        pweight: String? = nil
        
    ) {
        self.suitType = suitType
        self.Equipment = Equipment
        self.weight = weight
        self.pweight = pweight
    }
}

@Observable
class DiveEnvironment {
    var weather: String?    // 날씨
    var wind: String?       // 바람 상태
    var current: String?    // 조류 상태 (예: 약함, 강함 등)
    var wave: String?       // 파도 상태
    var airTemp: Int?    // 기온 (°C)
    var feelsLike: String?   // 체감온도 (°C)
    var waterTemp: Int?  // 수온 (°C)
    var visibility: String? // 시야 (예: 10m 등)
    
    init(
        weather: String? = nil,
        wind: String? = nil,
        current: String? = nil,
        wave: String? = nil,
        airTemp: Int? = nil,
        feelsLike: String? = nil,
        waterTemp: Int? = nil,
        visibility: String? = nil
    ) {
        self.weather = weather
        self.wind = wind
        self.current = current
        self.wave = wave
        self.airTemp = airTemp
        self.feelsLike = feelsLike
        self.waterTemp = waterTemp
        self.visibility = visibility
    }
}

@Observable
class DiveProfile {
    var diveTime: Int?        // 다이빙 시간 (분)
    var maxDepth: Int?     // 최대 수심 (m)
    var avgDepth: Int?     // 평균 수심 (m)
    var decoStop: Int?     // 감압 정지 시간 (분)
    var startPressure: Int?   // 시작 탱크 압력 (bar)
    var endPressure: Int?     // 종료 탱크 압력 (bar)
    
    
    init(
        diveTime: Int? = nil,
        maxDepth: Int? = nil,
        avgDepth: Int? = nil,
        decoStop: Int? = nil,
        startPressure: Int? = nil,
        endPressure: Int? = nil
    ) {
        self.diveTime = diveTime
        self.maxDepth = maxDepth
        self.avgDepth = avgDepth
        self.decoStop = decoStop
        self.startPressure = startPressure
        self.endPressure = endPressure
    }
}



