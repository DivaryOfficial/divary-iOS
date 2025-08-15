//
//  MainModel.swift
//  Divary
//
//  Created by chohaeun on 7/25/25.
//

import Foundation
import SwiftUI

// 추가: 저장 상태 enum
enum SaveStatus: String, CaseIterable {
    case complete = "COMPLETE"
    case temp = "TEMP"
}

// 수정: API 구조에 맞게 조정
struct LogBookBase: Identifiable {
    let id: String
    let logBaseInfoId: Int
    let date: Date
    let title: String
    let iconType: IconType
    let accumulation: Int
    var logBooks: [LogBook]
    
    // ✅ 추가: 연도별 조회용 saveStatus
    let saveStatus: SaveStatus?
    
    // 임시저장 상태 확인
    var hasTempSave: Bool {
        return saveStatus == .temp
    }
}

// 새로운: 개별 로그북 모델
struct LogBook: Identifiable {
    let id: String                  // logBookId를 String으로 변환
    let logBookId: Int              // 실제 API ID
    var saveStatus: SaveStatus
    var diveData: DiveLogData
}

// 실제 API Response 모델
struct LogBookBaseResponse {
    let logBases: [LogBookBase]
}

struct LogBookResponse {
    let logBooks: [DiveLogData]
}

enum IconType: String, CaseIterable, Identifiable {
    
    case plus // 추가 버튼
    case clownfish = "CLOWNFISH"            // clownfish → 흰동가리
    case butterflyfish = "BUTTERFLYFISH"    // butterflyfish → 나비고기
    case octopus = "OCTOPUS"                // octopus → 문어
    case cleanerWrasse = "CLEANER_WRASSE"   // anchovy(이미지) → 청줄놀래기
    case blackRockfish = "BLACK_ROCKFISH"   // blowfish(이미지) → 쏨배기
    case seaHare = "SEA_HARE"               // clam(이미지) → 군소
    case pufferfish = "PUFFERFISH"          // blowfish(이미지) → 복어
    case stripedBeakfish = "STRIPED_BEAKFISH" // longhornCowfish(이미지) → 돌돔
    case nudibranch = "NUDIBRANCH"          // seaSlug → 갯민숭달팽이
    case moonJellyfish = "MOON_JELLYFISH"   // combJelly → 보름달물해파리
    case yellowtailScad = "YELLOWTAIL_SCAD" // dolphin(이미지) → 줄전갱이
    case mantisShrimp = "MANTIS_SHRIMP"     // shrimp → 끄덕새우
    case seaTurtle = "SEA_TURTLE"           // turtle → 바다거북
    case starfish = "STARFISH"              // starfish → 불가사리
    case redLionfish = "RED_LIONFISH"       // lionfish → 쏠배감펭
    case seaUrchin = "SEA_URCHIN"           // squid(이미지) → 성게

    var id: String { self.rawValue }

    var image: Image {
        switch self {
        case .plus:
            return Image("plus")
        case .clownfish:
            return Image("clownfish")
        case .butterflyfish:
            return Image("butterflyfish")
        case .octopus:
            return Image("octopus")
        case .cleanerWrasse:
            return Image("anchovy") // 청줄놀래기
        case .blackRockfish:
            return Image("seaSlug") // 쏨배기
        case .seaHare:
            return Image("turtle") // 군소
        case .pufferfish:
            return Image("blowfish") // 복어
        case .stripedBeakfish:
            return Image("dolphin") // 돌돔
        case .nudibranch:
            return Image("longhornCowfish") // 갯민숭달팽이
        case .moonJellyfish:
            return Image("combJelly") // 보름달물해파리
        case .yellowtailScad:
            return Image("shrimp") // 줄전갱이
        case .mantisShrimp:
            return Image("crab") // 끄덕새우
        case .seaTurtle:
            return Image("lionfish") // 바다거북
        case .starfish:
            return Image("squid") // 불가사리
        case .redLionfish:
            return Image("clam") // 쏠배감펭
        case .seaUrchin:
            return Image("starfish") // 성게
        }
    }
}
