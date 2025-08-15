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
    @State private var diaryVM = DiaryMainViewModel()
    
    @State private var isCalendarPresented = false
    @State private var showCanvas = false

    // 저장 관련 상태
    @State private var showSavePopup = false
    @State private var showSavedMessage = false
    
    @State private var showDiaryLeavePopup = false
    private enum DiaryExitAction { case back, switchToLogbook }
    @State private var pendingDiaryExit: DiaryExitAction? = nil
    @State private var lastTab: DiveLogTab = .logbook
    @State private var allowDiaryExitOnce = false
    
    @Environment(\.dismiss) private var dismiss
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
//                         dismiss()
                        if selectedTab == .diary, diaryVM.hasUnsavedChanges {
                            pendingDiaryExit = .back
                            showDiaryLeavePopup = true
                        } else {
                            dismiss()
                        }
                      // 라우터 pop으로 일원화
                      container.router.pop()
                    },
//                    isTempSaved: (selectedTab == .diary ? diaryVM.canSave : viewModel.hasFrontendChanges),
                    isTempSaved: (selectedTab == .diary
                                  ? (diaryVM.saveButtonEnabled && !showCanvas)
                                  : viewModel.hasFrontendChanges), 
                    onSaveTap: {
                        if selectedTab == .diary {
                            diaryVM.manualSave() // 일기 저장
                        } else {
                            viewModel.handleSaveButtonTap(currentPageIndex: currentPageIndex) // 로그북 저장
                        }
                    }
                )
                .zIndex(1)

                TabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)

                Group {
                    switch selectedTab {
                    case .logbook:
                        LogBookPageView(
                                viewModel: viewModel,
                                onTitleTap: {
                                    editingTitle = viewModel.displayTitle
                                    showTitleEditPopup = true
                                },
                                onPageChanged: { newPageIndex in  // 추가
                                    currentPageIndex = newPageIndex
                                }
                            )
                    case .diary:
//                        DiaryMainView(diaryLogId: 0)
                        DiaryMainView(viewModel: diaryVM, diaryLogId: viewModel.logBaseInfoId, showCanvas: $showCanvas)
//                        DiaryMainView(diaryLogId: 51)
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
                        startMonth: Calendar.current.date(byAdding: .month, value: -999, to: Date())!,
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
            // 일기 날라가는거 경고 팝업
            if showDiaryLeavePopup {
                DeletePopupView(
                    isPresented: $showDiaryLeavePopup,
                    deleteText: "지금 나가면 일기의 변경 내용이 모두 삭제됩니다.",
                    onDelete: {
                        showDiaryLeavePopup = false
                        let action = pendingDiaryExit
                        pendingDiaryExit = nil
                        allowDiaryExitOnce = true
                        
                        DispatchQueue.main.async {
                            switch action {
                            case .back:
                                dismiss()
                            case .switchToLogbook:
                                selectedTab = .logbook
                            case .none:
                                break
                            }
                        }
                    }
                )
                .zIndex(999)
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
        .onChange(of: selectedTab) { oldTab, newTab in
            if allowDiaryExitOnce {
                allowDiaryExitOnce = false
                return
            }
            
            // 일기에서 나가려는 순간 + 변경사항 있음 → 팝업 띄우고 전환 취소
            if oldTab == .diary, newTab == .logbook, diaryVM.hasUnsavedChanges {
                selectedTab = .diary            // 되돌리기
                pendingDiaryExit = .switchToLogbook
                showDiaryLeavePopup = true
            }
        }

    }
}

#Preview { LogBookMainView(logBaseId: "1") }
