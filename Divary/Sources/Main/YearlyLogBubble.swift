//
//  YearlyLogBubble.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI

struct YearlyLogBubble: View {

    // 기존 코드에 추가: 각 로그 아이템에 logBaseId 추가
     let logItems: [(icon: IconType, date: Date, logBaseId: String)] = [
         (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 27).date!, "log_base_1"),
         (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 25).date!, "log_base_2"),
         (.octopus, DateComponents(calendar: .current, year: 2025, month: 7, day: 17).date!, "log_base_3"),
         // ... 기존 데이터에 logBaseId 추가
     ]
    
    // 추가: 필터링된 연도
    let selectedYear: Int
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    @Bindable var dataManager = MockDataManager.shared
    @Binding var showDeletePopup: Bool
    
    // 추가: 버블 탭 콜백
    var onBubbleTap: ((String) -> Void)?
    var onPlusButtonTap: (() -> Void)? // 추가: + 버튼 탭 콜백
    var onDeleteTap: ((String) -> Void)? 
    
    var body: some View {

        // MockDataManager에서 데이터 가져오기 + 연도 필터링 추가
        let filteredLogs = dataManager.logBookBases.filter { logBase in
            Calendar.current.component(.year, from: logBase.date) == selectedYear
        }
        let sortedLogs = filteredLogs.sorted { $0.date > $1.date }
        
        // 맨 앞에 .plus 추가
        let displayItems: [(icon: IconType, date: Date, logBaseId: String?)] =
            [(.plus, Date(), nil)] + sortedLogs.map { ($0.iconType, $0.date, $0.id) }
       
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                    LogBubbleCell(
                        iconType: item.icon,
                        logDate: item.date,
                        showDeletePopup: $showDeletePopup,
                        onTap: {
                            if item.icon == .plus {
                                onPlusButtonTap?() // + 버튼 클릭 시 새 로그 생성 플로우 시작
                            } else if let logBaseId = item.logBaseId {
                                onBubbleTap?(logBaseId) // 기존 로그 버블 클릭 시
                            }
                        }
                    )
                    .padding(.bottom, index % 2 == 0 ? 60 : 0)
                    .padding(.top, index % 2 == 1 ? 60 : 0)
                    
                    // 조건: 로그 없음 (+ 버튼에만 툴팁 표시)
                       if LogBookBaseMockData.isEmpty && index == 0 {
                           Image(.plusTooltip)
                               .offset(x: 60, y: -45)
                       }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

#Preview {
    @Previewable @State var showDeletePopup: Bool = false
    YearlyLogBubble(selectedYear: 2025, showDeletePopup: $showDeletePopup)
}
