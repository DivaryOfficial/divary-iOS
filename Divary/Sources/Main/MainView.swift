//
//  MainView.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedYear: Int = 2025
    @State private var showSwipeTooltip = false
    @State private var showDeletePopup = false
    @State private var showNotification = false
    @State private var notificationView = NotificationView()
    
    // 추가: 네비게이션 상태
    @State private var selectedLogBaseId: String? = nil
    @State private var showLogBookMain = false
    
    // 새 로그 생성 상태 추가
    @State private var newLogViewModel = NewLogCreationViewModel()
    
    // 나의바다로 가기 위한 변수들
    @State private var showCharacterView = false
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
        dataManager.logBookBases.first(where: { $0.id == selectedLogBaseId })
    }
    
    private var canSubYear: Bool {
        selectedYear > 1950
    }
    private var canAddYear: Bool {
        selectedYear < Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        ZStack {
            YearlyLogBubble(
                selectedYear: selectedYear,
                logBases: filteredLogBases, // API 데이터 전달
                showDeletePopup: $showDeletePopup,
                onBubbleTap: { logBaseId in
                    selectedLogBaseId = logBaseId
                    showLogBookMain = true
                },
                onPlusButtonTap: {
                    newLogViewModel.showNewLogCreation = true
                },
                onDeleteTap: { logBaseId in
                    selectedLogBaseId = logBaseId
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
                        // 기존 로그로 이동
                        selectedLogBaseId = logBaseId
                        showLogBookMain = true
                        newLogViewModel.resetData()
                    },
                    onCreateNewLog: {
                        // 새 로그 생성 (비동기 처리)
                        newLogViewModel.createNewLog { newLogBaseId in
                            DispatchQueue.main.async {
                                if let logBaseId = newLogBaseId, !logBaseId.isEmpty {
                                    selectedLogBaseId = logBaseId
                                    showLogBookMain = true
                                    // 새 로그 생성 후 해당 연도 데이터 새로고침
                                    refreshLogData()
                                }
                            }
                        }
                    }
                )
            }
            
            // 로딩 인디케이터
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView("로그 불러오는 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
        }
        .background(
            Image("seaBack")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
        )
        .task {
            // 최초 실행 시 한 번만 표시
            let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
            if !launched {
                showSwipeTooltip = true
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
            
            // 초기 데이터 로드
            await loadLogData()
        }
        .onChange(of: selectedYear) { _, newYear in
            // 연도 변경 시 데이터 새로고침
            Task {
                await loadLogData(for: newYear)
            }
        }
        .overlay {
            // 로그 삭제 확인 팝업
            if showDeletePopup, let log = selectedLogBase {
                let text: String = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/d"
                    return "\(formatter.string(from: log.date)) [\(log.title)] 을/를\n삭제하시겠습니까?"
                }()
                
                DeletePopupView(
                    isPresented: $showDeletePopup,
                    deleteText: text,
                    onConfirm: {
                        deleteSelectedLog()
                    }
                )
            }
            else if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "삭제하시겠습니까?")
            }
        }
        .navigationDestination(isPresented: $showLogBookMain) {
            if let logBaseId = selectedLogBaseId {
                LogBookMainView(logBaseId: logBaseId)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .fullScreenCover(isPresented: $showNotification) {
            NotificationView()
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < -50 {
                        showCharacterView = true
                    }
                }
        )
        .navigationDestination(isPresented: $showCharacterView) {
            CharacterView(isPetEditingMode: $isEditing)
        }
        .alert("오류", isPresented: .constant(errorMessage != nil)) {
            Button("확인") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private var yearSelectbar: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ZStack {
                    Button(action: {
                        showNotification = true
                    }) {
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
                Button(action: {
                    if canSubYear {
                        selectedYear -= 1
                    }
                }) {
                    Image("chevron.left")
                        .foregroundStyle(canSubYear ? .black : Color(.grayscaleG500))
                        .padding(.top, 8)
                }
                Spacer()
                
                YearDropdownPicker(selectedYear: $selectedYear)
                
                Spacer()
                Button(action: {
                    if canAddYear {
                        selectedYear += 1
                    }
                }) {
                    Image("chevron.right")
                        .foregroundStyle(canAddYear ? .black : Color(.grayscaleG500))
                        .padding(.top, 8)
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - API 관련 메서드
    
    @MainActor
    private func loadLogData(for year: Int? = nil) async {
        let targetYear = year ?? selectedYear
        isLoading = true
        errorMessage = nil
        
        dataManager.fetchLogList(for: targetYear) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    break // 성공적으로 로드됨
                case .failure(let error):
                    errorMessage = "로그 데이터를 불러올 수 없습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func refreshLogData() {
        Task {
            await loadLogData()
        }
    }
    
    private func deleteSelectedLog() {
        guard let logBase = selectedLogBase else { return }
        
        isLoading = true
        dataManager.deleteLogBase(logBaseInfoId: logBase.logBaseInfoId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    selectedLogBaseId = nil
                case .failure(let error):
                    errorMessage = "로그 삭제에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    MainView()
}
