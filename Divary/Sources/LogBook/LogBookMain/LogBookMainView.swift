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
    @Environment(\.diContainer) private var container
    
    @State var selectedTab: DiveLogTab = .logbook
    @State var viewModel: LogBookMainViewModel
    @State private var isCalendarPresented = false
    @State private var showCanvas = false
    
    // 저장 관련 상태
    @State private var showSavePopup = false
    @State private var showSavedMessage = false
    
    @State private var backupDate: Date = Date()
    @State private var tempMonth = Date()
    
    // 수정: logBaseId를 받는 init
    init(logBaseId: String) {
        _viewModel = State(initialValue: LogBookMainViewModel(logBaseId: logBaseId))
    }

    var body: some View {
        ZStack {
            // 로딩 화면
            if viewModel.isLoading {
                VStack {
                    ProgressView("로딩 중...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.8))
                .zIndex(100)
            }
            
            VStack(spacing: 0) {
                LogBookNavBar(
                    selectedDate: $viewModel.selectedDate,
                    isCalendarPresented: $isCalendarPresented,
                    onBackTap: {
                        // 라우터로 뒤로가기
                        container.router.pop()
                    },
                    isTempSaved: viewModel.isTempSaved,
                    onSaveTap: {
                        viewModel.handleSaveButtonTap()
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
            
            // 기존 팝업들...
            if isCalendarPresented {
                Color.white.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        backupDate = viewModel.selectedDate
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
            
            // SavePop 팝업
            if viewModel.showSavePopup {
                GeometryReader { geometry in
                    Color.white.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        SavePop(
                            onCompleteSave: {
                                viewModel.handleCompleteSave()
                            },
                            onTempSave: {
                                viewModel.handleTempSaveFromSavePopup()
                            },
                            onClose: {
                                viewModel.showSavePopup = false
                            }
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(25)
                }
            }
            
            // ComPop 팝업
            if viewModel.showSavedMessage {
                GeometryReader { geometry in
                    Color.white.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        ComPop(
                            onClose: {
                                viewModel.showSavedMessage = false
                            }
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(35)
                }
            }
        }
        .task {
            await viewModel.loadLogDetail()
        }
    }
}
