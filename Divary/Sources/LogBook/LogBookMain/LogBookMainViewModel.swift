//
//  LogBookPageViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI

@Observable
class LogBookMainViewModel {
    let diveLogData: [DiveLogData]
    var selectedDate = Date()
    var logCount: Int {
        3 - diveLogData.filter { $0.isEmpty }.count
    }

    init() {
        self.diveLogData = LogBookPageMock
    }
}
