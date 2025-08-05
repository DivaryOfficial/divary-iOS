//
//  LogBookPageViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI
//
//@Observable
//class LogBookMainViewModel {
//    var diveLogData: [DiveLogData]
//    var selectedDate = Date()
//    var logCount: Int {
//        3 - diveLogData.filter { $0.isEmpty }.count
//    }
//
//    init() {
//        self.diveLogData = LogBookPageMock
//    }
//}


// LogBookMainViewModel.swift 수정사항

@Observable
class LogBookMainViewModel {
    var diveLogData: [DiveLogData]
    var selectedDate = Date()
    var logBaseId: String
    var logBaseTitle: String = "" // 추가: 로그베이스 제목
    
    private let dataManager = MockDataManager.shared
    
    var logCount: Int {
        3 - diveLogData.filter { $0.isEmpty }.count
    }
    
    // 기존 init (기본값용)
      init() {
          self.logBaseId = ""
          self.diveLogData = LogBookPageMock
          self.logBaseTitle = "다이빙 로그북"
      }
    
    // logBaseId를 받는 init
       init(logBaseId: String) {
           self.logBaseId = logBaseId
           // MockDataManager에서 해당 logBaseId의 로그북들과 제목 가져오기
           if let logBase = dataManager.logBookBases.first(where: { $0.id == logBaseId }) {
               self.diveLogData = logBase.logBooks
               self.selectedDate = logBase.date
               self.logBaseTitle = logBase.title
           } else {
               self.diveLogData = [DiveLogData(), DiveLogData(), DiveLogData()]
               self.logBaseTitle = "새 다이빙 로그"
           }
       }
     
}
