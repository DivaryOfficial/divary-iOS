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
    case diary   = "일기"
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
    
    // 상태 변수 추가 (20줄 부근)
    @State private var currentPageIndex = 0

    // ✅ 제목 수정 관련 상태
    @State private var showTitleEditPopup = false
    @State private var editingTitle = ""

    // 날짜 변경 취소를 위한 백업데이터
    @State private var backupDate: Date = Date()

    // 백업데이터 변경없이 month 이동을 위한 사용자가 현재 보고있는 월 데이터
    @State private var tempMonth = Date()

    // logBaseId를 받는 init
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
                        // 라우터 pop으로 일원화
                        container.router.pop()
                    },
                    // ✅ 프론트엔드 임시저장 상태로 변경
                    isTempSaved: viewModel.hasFrontendChanges,
                    onSaveTap: {
                        viewModel.handleSaveButtonTap(currentPageIndex: currentPageIndex)
                    }
                )
                .zIndex(1)

                TabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)

                if selectedTab == .logbook {
                    LogBookPageView(
                        viewModel: viewModel,
                        onTitleTap: {
                            editingTitle = viewModel.displayTitle
                            showTitleEditPopup = true
                        },
                        onPageChanged: { pageIndex in
                            currentPageIndex = pageIndex
                        }
                    )
                }
                else {
                   // DiaryMainView()
                    if selectedTab == .diary {
                        DiaryMainView(diaryId: 0)
                        //DiaryMainView()
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

            // SavePop 팝업
            if viewModel.showSavePopup {
                GeometryReader { _ in
                    Color.white.opacity(0.5)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        SavePop(
                            onCompleteSave: { viewModel.handleCompleteSave(currentPageIndex: currentPageIndex) },
                            onTempSave: { viewModel.handleTempSaveFromSavePopup(currentPageIndex: currentPageIndex) },
                            onClose: { viewModel.showSavePopup = false }
                        )
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(25)
                }
            }

            // 저장 완료 메시지 (ComPop 사용)
            if viewModel.showSavedMessage {
                GeometryReader { _ in
                    Color.white.opacity(0.5)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        ComPop(onClose: { viewModel.showSavedMessage = false })
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(35)
                }
            }

            // ✅ 제목 수정 팝업 - updateFrontendTitle 메서드 사용
            if showTitleEditPopup {
                TitleEditPopup(
                    isPresented: $showTitleEditPopup,
                    title: $editingTitle,
                    onSave: {
                        viewModel.updateFrontendTitle(newTitle: editingTitle)
                        showTitleEditPopup = false
                    },
                    onCancel: {
                        showTitleEditPopup = false
                    }
                )
                .zIndex(45)
            }

            // 로딩 인디케이터
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView("처리 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .zIndex(40)
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview { LogBookMainView(logBaseId: "1") }
