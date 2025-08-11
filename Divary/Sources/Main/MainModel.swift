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
    let id: String                  // logBaseInfoId를 String으로 변환
    let logBaseInfoId: Int          // 실제 API ID
    let date: Date
    let title: String               // API의 name
    let iconType: IconType
    let accumulation: Int           // 총 다이빙 횟수
    var logBooks: [LogBook]         // 개별 로그북들 (최대 3개)
    
    // UI 호환성을 위한 computed property
    var logs: [DiveLogData] {
        return logBooks.map { $0.diveData }
    }
    
    // 임시저장 상태 확인
    var hasTempSave: Bool {
        return logBooks.contains { $0.saveStatus == .temp }
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
    case clownfish = "CLOWNFISH"
    case butterflyfish = "BUTTERFLYFISH"
    case octopus = "OCTOPUS"
    case anchovy = "ANCHOVY"
    case seaSlug = "SEASLUG"
    case turtle = "TURTLE"
    case blowfish = "BLOWFISH"
    case dolphin = "DOLPHIN"
    case longhornCowfish = "LONGHORNCOWFISH"
    case combJelly = "COMBJELLY"
    case shrimp = "SHRIMP"
    case crab = "CRAB"
    case lionfish = "LIONFISH"
    case squid = "SQUID"
    case clam = "CLAM"
    case starfish = "STARFISH"

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
        case .anchovy:
            return Image("anchovy")
        case .seaSlug:
            return Image("seaSlug")
        case .turtle:
            return Image("turtle")
        case .blowfish:
            return Image("blowfish")
        case .dolphin:
            return Image("dolphin")
        case .longhornCowfish:
            return Image("longhornCowfish")
        case .combJelly:
            return Image("combJelly")
        case .shrimp:
            return Image("shrimp")
        case .crab:
            return Image("crab")
        case .lionfish:
            return Image("lionfish")
        case .squid:
            return Image("squid")
        case .clam:
            return Image("clam")
        case .starfish:
            return Image("starfish")
        }
    }
}
