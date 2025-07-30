//
//  MainViewModel.swift
//  Divary
//
//  Created by chohaeun on 7/25/25.
//

import Foundation
import Combine


class MainViewModel: ObservableObject {
    @Published var logGroups: [DiveLogGroup] = []        // 날짜별 로그 + 아이콘
    @Published var landingItems: [LogListItem] = []  // 버튼 표시용 요약

    init(groups: [DiveLogGroup]) {
        self.logGroups = groups
        self.landingItems = groups.map {
            LogListItem(date: $0.date, iconType: $0.iconType)
        }
    }

    func logs(for date: String) -> [DiveLogData] {
        return logGroups.first(where: { $0.date == date })?.logs ?? []
    }
}



