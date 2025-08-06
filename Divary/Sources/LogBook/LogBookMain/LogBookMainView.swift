//
//  LogBookMain.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import SwiftUI

//상단 탭 enum
enum DiveLogTab: String, CaseIterable {
    case logbook = "로그북"
    case diary = "일기"
}

struct LogBookMainView: View {
    @State var selectedTab: DiveLogTab = .logbook
    @State var viewModel: LogBookMainViewModel
    @State private var isCalendarPresented = false
    @State private var showCanvas = false
    
    //날짜 변경 취소를 위한 백업데이터
    @State private var backupDate: Date = Date()
    
    // 백업데이터 변경없이 month 이동을 위한 사용자가 현재 보고있는 월 데이터 - 캘린더 month 변경시 변경
    @State private var tempMonth = Date()
    
    // 추가: 뒤로가기를 위한 환경변수
      @Environment(\.dismiss) private var dismiss
    
    // 수정: logBaseId를 받는 init
       init(logBaseId: String) {
           _viewModel = State(initialValue: LogBookMainViewModel(logBaseId: logBaseId))
       }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                LogBookNavBar(
                                 selectedDate: $viewModel.selectedDate,
                                 isCalendarPresented: $isCalendarPresented,
                                 onBackTap: {
                                     dismiss()
                                 },
                                 isTempSaved: viewModel.isTempSaved,
                                                    onSaveTap: {
                                                        // 저장 버튼 액션 (필요시 구현)
                                                        print("저장 버튼 클릭됨")
                                                    }
                             )
                             .zIndex(1)
                TabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)

                Group {
                    switch selectedTab {
                    case .logbook:
                        LogBookPageView(viewModel: viewModel)
                    case .diary:
                        DiaryMainView()
                    }
                }
            }
            
            // 날짜 클릭시 팝업
            if isCalendarPresented {
                Color.white.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        backupDate = viewModel.selectedDate  // 백업
                        isCalendarPresented = false
                    }

                VStack(spacing: 0) {
                    CalenderNavBar(selectedDate: $backupDate, isCalendarPresented: $isCalendarPresented)
                        .zIndex(1)
                        .padding(.bottom, 1)
                    
                    CalenderView(
                        currentMonth: $tempMonth,
                        selectedDate: $backupDate,
                        startMonth: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                        endMonth: Calendar.current.date(byAdding: .month, value: 3, to: Date())!
                    )
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                    

                    HStack(spacing: 16) {
                        Button("취소") {
                            isCalendarPresented = false
                        }
                        .font(Font.omyu.regular(size: 16))
                        .frame(maxWidth: 114)
                        .padding()
                        .background(Color.grayscale_g200)
                        .foregroundStyle(Color.grayscale_g500)
                        .cornerRadius(8)
                        

                        Button("저장") {
                            viewModel.selectedDate = backupDate
                            isCalendarPresented = false
                        }
                        .font(Font.omyu.regular(size: 16))
                        .frame(maxWidth: 114)
                        .padding()
                        .background(Color.primary_sea_blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    

                }
                
            }
        }
    }
}

#Preview {
    LogBookMainView(logBaseId: "log_base_1")
}
