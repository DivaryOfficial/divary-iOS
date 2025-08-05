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
    
    // 추가: 탭 콜백
    var onTap: (() -> Void)?
    
    // 추가: 임시저장 상태 표시를 위한 프로퍼티
    var hasTempSave: Bool = false

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
                      
                      // 추가: 빨간점 표시 (임시저장이 있는 경우)
                      if hasTempSave && iconType != .plus {
                          Circle()
                              .fill(Color.red)
                              .frame(width: 12, height: 12)
                              .offset(x: 15, y: -25)
                          }
                  }
                  if iconType != .plus {
                      Text(formattedDate)
                          .font(Font.omyu.regular(size: 20))
                  }
                  else {
                      Text(" ")
                  }
              }
              .scaleEffect(showDeleteButton ? 1.3 : 1.0)
              .animation(.easeInOut(duration: 0.2), value: showDeleteButton)
              .onTapGesture {
                  if !showDeleteButton {
                      onTap?()
                  }
              }
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
    LogBubbleCell(iconType: .clownfish, logDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!, showDeletePopup: $showDeletePopup, hasTempSave: true)
}
