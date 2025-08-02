//
//  YearlyLogBubble.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI

struct YearlyLogBubble: View {
    let logItems: [(icon: IconType, date: Date)] = [
        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 27).date!),
        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 25).date!),
        (.octopus, DateComponents(calendar: .current, year: 2025, month: 7, day: 17).date!),
        (.turtle, DateComponents(calendar: .current, year: 2025, month: 7, day: 14).date!),
        (.anchovy, DateComponents(calendar: .current, year: 2025, month: 7, day: 3).date!),
        (.clownfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 28).date!),
        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 8, day: 1).date!),
//        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 27).date!),
//        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 25).date!),
//        (.octopus, DateComponents(calendar: .current, year: 2025, month: 7, day: 17).date!),
//        (.turtle, DateComponents(calendar: .current, year: 2025, month: 7, day: 14).date!),
//        (.anchovy, DateComponents(calendar: .current, year: 2025, month: 7, day: 3).date!),
//        (.clownfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 28).date!),
//        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
//        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
//        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 27).date!),
//        (.blowfish, DateComponents(calendar: .current, year: 2025, month: 7, day: 25).date!),
//        (.octopus, DateComponents(calendar: .current, year: 2025, month: 7, day: 17).date!),
//        (.turtle, DateComponents(calendar: .current, year: 2025, month: 7, day: 14).date!),
//        (.anchovy, DateComponents(calendar: .current, year: 2025, month: 7, day: 3).date!),
//        (.clownfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 28).date!),
//        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
//        (.longhornCowfish, DateComponents(calendar: .current, year: 2025, month: 6, day: 19).date!),
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    @Binding var showDeletePopup: Bool
    
    var body: some View {
        // 로그 정렬
        let sortedLogs = logItems.sorted { $0.date > $1.date }
        // 맨 앞에 .plus 추가
        let displayItems: [(icon: IconType, date: Date)] = [(.plus, Date())] + sortedLogs
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                    LogBubbleCell(iconType: item.icon, logDate: item.date, showDeletePopup: $showDeletePopup)
                        .padding(.bottom, index % 2 == 0 ? 60 : 0)
                        .padding(.top, index % 2 == 1 ? 60 : 0)
                    
                    // 조건: 로그 없음
                    if logItems.isEmpty {
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
    YearlyLogBubble(showDeletePopup: $showDeletePopup)
}
