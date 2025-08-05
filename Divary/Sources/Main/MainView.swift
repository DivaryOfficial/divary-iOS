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
    
    // 연도별 필터링된 로그베이스들
       private var filteredLogBases: [LogBookBaseMock] {
           MockDataManager.shared.logBookBases.filter { logBase in
               Calendar.current.component(.year, from: logBase.date) == selectedYear
           }
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
                background
                
                YearlyLogBubble(
                                  selectedYear: selectedYear, // 선택된 연도 전달
                                  showDeletePopup: $showDeletePopup,
                                  onBubbleTap: { logBaseId in
                                      selectedLogBaseId = logBaseId
                                      showLogBookMain = true
                                  },
                                  onPlusButtonTap: {// + 버튼 탭 시 새 로그 생성 플로우 시작
                                      newLogViewModel.showNewLogCreation = true
                                  }
                              )
                .padding(.top, 150)
                
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
            .task {
                // 최초 실행 시 한 번만 표시
                let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
                if !launched {
                    showSwipeTooltip = true
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                }
            }
            .overlay {
                if showDeletePopup {
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
        }
    }
    
    private var background: some View {
        Image("seaBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    private var yearSelectbar: some View {
        
        VStack(spacing: 0) {
            HStack {
                Spacer()
                // 벨 버튼 부분을 다음과 같이 수정
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
                }.padding(.trailing, 12)
                
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 55)
            }
            .padding(.bottom, 3)
            
            HStack(alignment: .top) {
                Button(action: {
                    if canSubYear {
                        selectedYear -= 1
                    }
                }) {
                    Image("chevron.left")
                        .foregroundStyle(canSubYear ? .black : Color(.grayscaleG500))
                }
                .padding(.top, 8)
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
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 12)
            
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
