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
    
    @State private var showDeleteButton = false
    @Binding var showDeletePopup: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: logDate)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                ZStack {
                    Image(.bubble)
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
            .scaleEffect(showDeleteButton ? 1.3 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: showDeleteButton)
            .onLongPressGesture {
                if iconType != .plus {
                    withAnimation {
                        showDeleteButton = true
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                if showDeleteButton { // 로그 삭제버튼 띄우기
                    Button(action: {
                        showDeleteButton = false
                        showDeletePopup = true
                    }) {
                        Image(.deleteFloating)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                    .offset(x: 70, y: -30)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showDeletePopup: Bool = false
    LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!, showDeletePopup: $showDeletePopup)
}
