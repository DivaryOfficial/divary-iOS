//
//  MainModel.swift
//  Divary
//
//  Created by chohaeun on 7/25/25.
//


import Foundation
import SwiftUI


struct LogListItem: Identifiable {
    let id = UUID()
    let date: String              // 날짜 (예: "2022-01-23")
    let iconType: IconType          // 대표 아이콘 코드 (예: "CLOWNFISH")
}

struct DiveLogGroup: Identifiable {
    let id = UUID()
    var date: String
    var iconType: IconType        // ✅ 날짜별 대표 아이콘
    var logs: [DiveLogData]     // 최대 3개
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



//@Observable
//class MainLogs {
//    var name: String?   // 로그 제목
//    var date: String?   // 로그 날짜
//    var iconType: String? // 로그 아이콘
//    var saveStatus: Bool? // 임시저장 상태
//    
//    init(
//        name: String? = nil,
//        date: String? = nil,
//        iconType: String? = nil,
//        saveStatus: Bool? = nil
//    ) {
//        self.name = name
//        self.date = date
//        self.iconType = iconType
//        self.saveStatus = saveStatus
//    }
//}

