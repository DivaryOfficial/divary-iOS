//
//  LogBubbleCell.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI

struct LogBubbleCell: View {
    var iconType: IconType
    var logDate: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: logDate)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Image(.bubble)
                    .blur(radius: 3)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
                iconType.image
            }
            if iconType != .plus { // 로그북 버블일 때
                Text(formattedDate)
                    .font(Font.omyu.regular(size: 20))
            }
            else { // .plus일 때
                Text(" ") // 플러스 버튼일 때도 높이 맞추기 위해서
            }
        }
    }
}

#Preview {
    LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!)
}
