//
//  YearlyLogBubble.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI

struct YearlyLogBubble: View {
    var body: some View {
        HStack {
            LogBubbleCell(iconType: .plus, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!)
            LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!)
            LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!)
            LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!)
        }
    }
}

#Preview {
    YearlyLogBubble()
}
