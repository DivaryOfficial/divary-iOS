//
//  YearlyLogBubble.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI
import Foundation

struct YearlyLogBubble: View {
    let selectedYear: Int
    let logBases: [LogBookBase]  // 외부에서 전달받은 데이터
    @Binding var showDeletePopup: Bool
    var onBubbleTap: ((String) -> Void)?
    var onPlusButtonTap: (() -> Void)?
    var onDeleteTap: ((String) -> Void)?
    
    // 그리드 컬럼 설정
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    @AppStorage("hasSeenPlusTooltip") private var hasSeenPlusTooltip: Bool = false
    
    var body: some View {
        // 전달받은 logBases에서 해당 연도 필터링
        let filteredLogs = logBases.filter { logBase in
            Calendar.current.component(.year, from: logBase.date) == selectedYear
        }
        let sortedLogs = filteredLogs.sorted { $0.date > $1.date }
        
        // 맨 앞에 .plus 추가
        let displayItems: [(icon: IconType, date: Date, logBaseId: String?, hasTempSave: Bool)] =
            [(.plus, Date(), nil, false)] +
            sortedLogs.map { ($0.iconType, $0.date, $0.id, $0.hasTempSave) }
        
        let shouldShowTooltip = sortedLogs.isEmpty && !hasSeenPlusTooltip
       
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
                        },
                        onLongTap: {
                            if let logBaseId = item.logBaseId {
                                onDeleteTap?(logBaseId)
                            }
                        },
                        hasTempSave: item.hasTempSave
                    )
                    .padding(.bottom, index % 2 == 0 ? 60 : 0)
                    .padding(.top, index % 2 == 1 ? 60 : 0)
                    
                    // 조건: 로그 없음 (+ 버튼에만 툴팁 표시)
//                    if sortedLogs.isEmpty && index == 0 {
//                        Image(.plusTooltip)
//                            .offset(x: 60, y: -45)
//                    }
                    if shouldShowTooltip && index == 0 {
                        Image(.plusTooltip)
                            .offset(x: 60, y: -45)
                            .task { hasSeenPlusTooltip = true }
                    }
                }
            }
            .padding()
        }
    }
}

//
//#Preview {
//    @Previewable @State var showDeletePopup = false
//    
//    // 프리뷰용 샘플 데이터
//    let sampleLogBases = [
//        LogBookBase(
//            id: "1",
//            logBaseInfoId: 1,
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!,
//            title: "제주도 다이빙",
//            iconType: .clownfish,
//            accumulation: 3,
//            logBooks: []
//        ),
//        LogBookBase(
//            id: "2",
//            logBaseInfoId: 2,
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
//            title: "울릉도 다이빙",
//            iconType: .turtle,
//            accumulation: 2,
//            logBooks: []
//        )
//    ]
//    
//    YearlyLogBubble(
//        selectedYear: 2025,
//        logBases: sampleLogBases,
//        showDeletePopup: $showDeletePopup
//    )
//}
