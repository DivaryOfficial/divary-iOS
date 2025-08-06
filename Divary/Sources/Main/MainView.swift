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
    
    // 연도별 필터링된 로그베이스들
    private var filteredLogBases: [LogBookBaseMock] {
       MockDataManager.shared.logBookBases.filter { logBase in
           Calendar.current.component(.year, from: logBase.date) == selectedYear
       }
    }
    
    private var selectedLogBase: LogBookBaseMock? {
        MockDataManager.shared.logBookBases.first(where: { $0.id == selectedLogBaseId })
    }
    
    private var canSubYear: Bool {
        selectedYear > 1950
    }
    private var canAddYear: Bool {
        selectedYear < Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                YearlyLogBubble(
                    selectedYear: selectedYear, // 선택된 연도 전달
                    showDeletePopup: $showDeletePopup,
                    onBubbleTap: { logBaseId in
                      selectedLogBaseId = logBaseId
                      showLogBookMain = true
                    },
                    onPlusButtonTap: {// + 버튼 탭 시 새 로그 생성 플로우 시작
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
                        viewModel: newLogViewModel, onNavigateToExistingLog: { logBaseId in
                            // 기존 로그로 이동
                            selectedLogBaseId = logBaseId
                            showLogBookMain = true
                            newLogViewModel.resetData()
                        },
                        onCreateNewLog: {
                            // 새 로그 생성 후 해당 로그로 이동
                            let newLogBaseId = newLogViewModel.createNewLog()
                            if !newLogBaseId.isEmpty {
                                selectedLogBaseId = newLogBaseId
                                showLogBookMain = true
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
                // 최초 실행 시 한 번만 표시
                let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
                if !launched {
                    showSwipeTooltip = true
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                }
            }
            .overlay { // 로그 삭제 확인 팝업
                if showDeletePopup, let log = selectedLogBase {
                    let text: String = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "M/d"
                        return "\(formatter.string(from: log.date)) [\(log.title)] 을/를\n삭제하시겠습니까?"
                    }()
                    
                    DeletePopupView(isPresented: $showDeletePopup, deleteText: text)
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
            .gesture( // 나의 바다 뷰로 이동
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        // 오른쪽 → 왼쪽 스와이프 감지
                        if value.translation.width < -50 {
                            let _ = print("스와이프햇다1")
                            showCharacterView = true
                        }
                    }
            )
            .navigationDestination(isPresented: $showCharacterView) { // 나의 바다 뷰로 이동
                CharacterView(isPetEditingMode: $isEditing)
            }
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
                    
                    // 안 읽은 알림이 있으면 빨간점 표시
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

#Preview {
    MainView()
}
