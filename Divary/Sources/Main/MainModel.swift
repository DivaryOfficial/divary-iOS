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

struct LogBookBase: Identifiable{
    let id: String
    let date: Date
    let title: String
    let iconType: IconType
    var logs: [DiveLogData]     // 최대 3개
    var saveStatus: SaveStatus = .complete // 추가: 저장 상태
    // API에서 받을 때는 로그북 데이터는 별도 API로 가져올지도
    // var logBooks: [DiveLogData] // 이건 별도 API 호출로 가져올 예정
}

// 실제 API Response 모델
struct LogBookBaseResponse{
    let logBases: [LogBookBase]
}

struct LogBookResponse {
    let logBooks: [DiveLogData]
}

enum IconType: String, CaseIterable, Identifiable {
    case plus // 추가 버튼
    case clownfish
    case butterflyfish
    case octopus
    case anchovy
    case seaSlug
    case turtle
    case blowfish
    case dolphin
    case longhornCowfish
    case combJelly
    case shrimp
    case crab
    case lionfish
    case squid
    case clam
    case starfish

    var id: String { self.rawValue }

    var image: Image {
        switch self {
        case .plus:
            return Image("plus")
        default:
            return Image(rawValue)
        }
    }

//    var displayName: String {
//        switch self {
//        case .plus: return "+"
//        case .clownfish: return "흰동가리"
//        case .butterflyfish: return "나비고기"
//        case .octopus: return "문어"
//        case .anchovy: return "청줄놀래기"
//        case .seaSlug: return "쏨뱅이"
//        case .turtle: return "군소"
//        case .blowfish: return "복어"
//        case .dolphin: return "돌돔"
//        case .longhornCowfish: return "갯민숭달팽이"
//        case .combJelly: return "보름달물해파리"
//        case .shrimp: return "줄전갱이"
//        case .crab: return "꼬덕새우"
//        case .lionfish: return "바다거북"
//        case .squid: return "불가사리"
//        case .clam: return "쏠배감펭"
//        case .starfish: return "성게"
//        }
//    }
}
