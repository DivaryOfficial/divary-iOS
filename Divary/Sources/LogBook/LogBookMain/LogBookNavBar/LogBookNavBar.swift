//
//  LogBookNavBar.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct LogBookNavBar: View {
    @Binding var selectedDate: Date
    @Binding var isCalendarPresented: Bool
    @State private var showTooltip = false

    // 추가: 뒤로가기 콜백 (옵셔널)
       var onBackTap: (() -> Void)? = nil
    
    var body: some View {
        ZStack() {
            HStack{
                Button(action: {
                    onBackTap?()
                }) {
                    Image("chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                Button {
                    isCalendarPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedDateFormatted)
                            .font(Font.omyu.regular(size: 20))
                            .foregroundStyle(.black)
                            .padding(.vertical, 6)
                    }
                }
                
                
                ZStack{
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showTooltip = true
                        }
                        
                        // 2초 뒤 서서히 사라지기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showTooltip = false
                            }
                        }
                    }) {
                        Image("LogBookLock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.bw_black)
                            .frame(width: 24)
                        
                    }
                }.overlay(
                    Group {
                        if showTooltip {
                            Image("Tooltip")
                                .resizable()
                                .frame(width: 255, height: 66)
                                .transition(.opacity)
                                .offset(x: -65)
                                .offset(y: 70)
                                .zIndex(10) // 위로 띄우기
                        }
                    },
                    alignment: .bottom
                )
                
                
                Spacer()
                
                Text("저장")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(.gray)
            }
        }
        .padding(12)
        .background(Color.white)
    }
    
    private var selectedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: selectedDate)
    }
}



#Preview {
    LogBookNavBar(
        selectedDate: .constant(Date()),
        isCalendarPresented: .constant(true)
    )
}
