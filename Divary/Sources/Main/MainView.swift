//
//  MainView.swift - API 연결로 수정
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct MainView: View {
    @Environment(\.diContainer) private var container
    
    @State private var selectedYear: Int = 2025
    @State private var showSwipeTooltip = false
    @State private var showDeletePopup = false
    @State private var showNotification = false
    @State private var isLoading = false
    
    // 선택된 로그 ID (삭제용)
    @State private var selectedLogBaseId: String? = nil
    
    // 새 로그 생성 상태
    @State private var newLogViewModel = NewLogCreationViewModel()
    
    // API 데이터 매니저
    @State private var dataManager = LogBookDataManager.shared
    
    // 연도별 필터링된 로그베이스들
    private var filteredLogBases: [LogBookBase] {
       dataManager.logBookBases.filter { logBase in
           Calendar.current.component(.year, from: logBase.date) == selectedYear
       }
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
            // 로딩 화면
            if isLoading {
                VStack {
                    ProgressView("로딩 중...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.8))
                .zIndex(100)
            }
            
            YearlyLogBubble(
                selectedYear: selectedYear,
                showDeletePopup: $showDeletePopup,
                onBubbleTap: { logBaseId in
                    // 라우터로 네비게이션
                    container.router.push(.logBookMain(logBaseId: logBaseId))
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
                        // 라우터로 네비게이션
                        container.router.push(.logBookMain(logBaseId: logBaseId))
                        newLogViewModel.resetData()
                    },
                    onCreateNewLog: {
                        Task {
                            if let newLogBaseId = await newLogViewModel.createNewLog() {
                                await MainActor.run {
                                    // 라우터로 네비게이션
                                    container.router.push(.logBookMain(logBaseId: newLogBaseId))
                                }
                            }
                        }
                    }
                )
            }
        }
        .background(
            Image("seaBack")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
        )
        .task {
            await dataManager.loadLogs(for: selectedYear)
            
            let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
            if !launched {
                showSwipeTooltip = true
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
        }
        .onChange(of: selectedYear) { oldValue, newValue in
            Task {
                isLoading = true
                await dataManager.loadLogs(for: newValue)
                isLoading = false
            }
        }
        .overlay {
            // 삭제 확인 팝업
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
                        Task {
                            if let logId = selectedLogBaseId {
                                let success = await dataManager.deleteLog(id: logId)
                                if success {
                                    selectedLogBaseId = nil
                                }
                            }
                        }
                    }
                )
            }
            else if showDeletePopup {
                DeletePopupView(
                    isPresented: $showDeletePopup,
                    deleteText: "삭제하시겠습니까?",
                    onConfirm: {
                        Task {
                            if let logId = selectedLogBaseId {
                                let success = await dataManager.deleteLog(id: logId)
                                if success {
                                    selectedLogBaseId = nil
                                }
                            }
                        }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showNotification) {
            NotificationView()
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < -50 {
                        // 라우터로 네비게이션
                        container.router.push(.CharacterViewWrapper)
                    }
                }
        )
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
}

