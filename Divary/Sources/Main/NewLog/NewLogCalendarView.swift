//
//  NewLogCalendarView.swift
//  Divary
//
//  Created by chohaeun on 8/18/25.
//
import SwiftUI

// 캘린더 선택 뷰
struct NewLogCalendarView: View {
    @Bindable var viewModel: NewLogCreationViewModel
    @State private var tempMonth = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("날짜선택")
                .font(Font.omyu.regular(size: 20))
                .padding(.leading, 16)
                .padding(.top, 22)
            
            // 캘린더 (기존 CalenderView 재사용)
            NewCalenderView(
                currentMonth: $tempMonth,
                selectedDate: $viewModel.selectedDate,
                startMonth: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
                endMonth: Calendar.current.date(byAdding: .month, value: 12, to: Date())!
            )
            .padding(.horizontal)
            
            // 완료 버튼
            Button("날짜 선택 완료") {
                viewModel.proceedToNextStep()
            }
            .font(Font.omyu.regular(size: 16))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primary_sea_blue)
            .foregroundStyle(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(viewModel.isLoading)
        }
    }
}
