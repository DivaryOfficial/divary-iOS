//
//  MainView.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

// 라우터/DI 주입 일관화를 위한 래퍼
struct MainWrapperView: View {
    @Environment(\.diContainer) private var container
    var body: some View {
        MainView()
    }
}

struct MainView: View {
    @Environment(\.diContainer) private var container

    @State private var selectedYear: Int = 2025
    @State private var showSwipeTooltip = false
    @State private var showDeletePopup = false

    // 삭제 팝업용으로만 사용하는 선택값
    @State private var selectedForDeleteId: String? = nil

    // 새 로그 생성 플로우 상태
    @State private var newLogViewModel = NewLogCreationViewModel()

    // 캐릭터(나의 바다) 관련
    @State private var isEditing = false

    // API 연동 관련
    @State private var dataManager = LogBookDataManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 연도별 필터링된 로그베이스들 (API 기반)
    private var filteredLogBases: [LogBookBase] {
        dataManager.getLogBases(for: selectedYear)
    }

    private var selectedLogBase: LogBookBase? {
        guard let id = selectedForDeleteId else { return nil }
        return dataManager.logBookBases.first(where: { $0.id == id })
    }

    private var canSubYear: Bool { selectedYear > 1950 }
    private var canAddYear: Bool { selectedYear < Calendar.current.component(.year, from: Date()) }

    var body: some View {
        ZStack {
            YearlyLogBubble(
                selectedYear: selectedYear,
                logBases: filteredLogBases,
                showDeletePopup: $showDeletePopup,
                onBubbleTap: { logBaseId in
                    // 라우터로 상세 화면 이동
                    container.router.push(.logBookMain(logBaseId: logBaseId))
                },
                onPlusButtonTap: {
                    newLogViewModel.showNewLogCreation = true
                },
                onDeleteTap: { logBaseId in
                    selectedForDeleteId = logBaseId
                    showDeletePopup = true
                }
            )
            .padding(.top, 110)

            if showSwipeTooltip {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(.swipeTooltip)
                            .padding(.trailing, 20)
                            .transition(.opacity)
                    }
                    .padding(.bottom, 200)
                }
            }

            yearSelectbar
            
            // 새 로그 생성 플로우
            if newLogViewModel.showNewLogCreation {
                NewLogCreationView(
                    viewModel: newLogViewModel,
                    onNavigateToExistingLog: { logBaseId in
                        container.router.push(.logBookMain(logBaseId: logBaseId))
                        newLogViewModel.resetData()
                    },
                    onCreateNewLog: {
                        newLogViewModel.createNewLog { newLogBaseId in
                            DispatchQueue.main.async {
                                print("📍 onCreateNewLog 콜백 받음: \(String(describing: newLogBaseId))")
                                if let logBaseId = newLogBaseId, !logBaseId.isEmpty {
                                    print("🚀 라우터 이동 시도: logBaseId=\(logBaseId)")
                                    container.router.push(.logBookMain(logBaseId: logBaseId))
                                    print("✅ 라우터 push 완료")
                                    newLogViewModel.resetData()
                                    refreshLogData()
                                } else {
                                    print("❌ logBaseId가 nil이거나 빈 문자열")
                                }
                            }
                        }
                    }
                )
            }

            // 로딩 인디케이터
            if isLoading {
                LoadingOverlay(message: "로그 불러오는 중...")
            }
        }
        .background(
            Image("seaBack")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
        )
        .task {
            // 최초 실행 시 한 번만 툴팁 표시
            let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
            if !launched {
                showSwipeTooltip = true
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }

            // 초기 데이터 로드
            await loadLogData()
        }
        .onChange(of: selectedYear) { _, newYear in
            Task { await loadLogData(for: newYear) }
        }
        .overlay {
            // 로그 삭제 확인 팝업
            if showDeletePopup, let log = selectedLogBase {
                let text: String = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/d"
                    return "\(formatter.string(from: log.date)) [\(log.title)] 을/를\n삭제하시겠습니까?"
                }()

                DelPop(
                    isPresented: $showDeletePopup,
                    deleteText: text,
                    onConfirm: { deleteSelectedLog() }
                )
            } else if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "삭제하시겠습니까?")
            }
        }
        .alert("오류", isPresented: .constant(errorMessage != nil)) {
            Button("확인") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var yearSelectbar: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button {
                    container.router.push(.CharacterViewWrapper)
                } label: {
                    Image("seashell")
                        .foregroundStyle(.black)
                }
                
                ZStack {
                    Button {
                        container.router.push(.notifications)
                    } label: {
                        Image("bell-1")
                            .foregroundStyle(.black)
                    }

                    if NotificationManager.shared.unreadCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 8, y: -8)
                    }
                }
            }
            .padding(.trailing)

            HStack(alignment: .top, spacing: 0) {
                Button {
                    if canSubYear { selectedYear -= 1 }
                } label: {
                    Image("chevron.left")
                        .foregroundStyle(canSubYear ? .black : Color(.grayscaleG500))
                        .padding(.top, 8)
                }
                Spacer()

                YearDropdownPicker(selectedYear: $selectedYear)

                Spacer()
                Button {
                    if canAddYear { selectedYear += 1 }
                } label: {
                    Image("chevron.right")
                        .foregroundStyle(canAddYear ? .black : Color(.grayscaleG500))
                        .padding(.top, 8)
                }
            }
            .padding()

            Spacer()
        }
    }

    // MARK: - API

    @MainActor
    private func loadLogData(for year: Int? = nil) async {
        let targetYear = year ?? selectedYear
        isLoading = true
        errorMessage = nil

        dataManager.fetchLogList(for: targetYear) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success: break
                case .failure(let error):
                    errorMessage = "로그 데이터를 불러올 수 없습니다: \(error.localizedDescription)"
                }
            }
        }
    }

    private func refreshLogData() {
        Task { await loadLogData() }
    }

    private func deleteSelectedLog() {
        guard let logBase = selectedLogBase else { return }

        isLoading = true
        dataManager.deleteLogBase(logBaseInfoId: logBase.logBaseInfoId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    selectedForDeleteId = nil
                case .failure(let error):
                    errorMessage = "로그 삭제에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview { MainWrapperView() }
