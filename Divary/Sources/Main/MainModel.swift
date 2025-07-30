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
    let iconType: String          // 대표 아이콘 코드 (예: "CLOWNFISH")
}

struct DiveLogGroup: Identifiable {
    let id = UUID()
    var date: String
    var iconType: String        // ✅ 날짜별 대표 아이콘
    var logs: [DiveLogData]     // 최대 3개
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

