//
//  LogBookPageView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI
import Foundation

struct LogBookPageView: View {
    @Bindable var mainViewModel: LogBookMainViewModel
    @State private var pageViewModel: LogBookPageViewModel
    
    // ✅ 추가: 제목 클릭 콜백
    var onTitleTap: (() -> Void)? = nil
    
    // NewLogPop 관련 상태
    @State private var showNewLogPop = false
    @State private var showMaxLogError = false
    
    // ✅ init 수정 - onTitleTap 파라미터 추가
    init(viewModel: LogBookMainViewModel, onTitleTap: (() -> Void)? = nil) {
        self._mainViewModel = Bindable(viewModel)
        self._pageViewModel = State(initialValue: LogBookPageViewModel(mainViewModel: viewModel))
        self.onTitleTap = onTitleTap
    }
    
    var body: some View {
        ZStack{
            TabView(selection: $pageViewModel.selectedPage) {
                ForEach(Array(mainViewModel.diveLogData.enumerated()), id: \.offset) { index, _ in
                    let data = $mainViewModel.diveLogData[index]
                    
                    ScrollView {
                        ZStack(alignment: .topLeading) {
                            GeometryReader { geometry in
                                Image("gridBackground")
                                    .resizable(resizingMode: .tile)
                                    .frame(
                                        width: geometry.size.width,
                                        height: max(geometry.size.height, UIScreen.main.bounds.height)
                                    )
                            }.ignoresSafeArea()
                            
                            LazyVStack(alignment: .leading, spacing: 18) {
                                // ✅ 제목 버튼 (기존 코드 유지)
                                Button(action: {
                                    onTitleTap?()
                                }) {
                                    Text(mainViewModel.displayTitle)
                                        .font(Font.omyu.regular(size: 20))
                                        .foregroundColor(.black)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                }

                                // ✅ 완전저장 상태를 각 섹션에 전달
                                DiveOverviewSection(
                                    overview: data.overview,
                                    isSaved: .constant(isCompleteSaved(index))
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .overview
                                }
                                
                                HStack(alignment: .top) {
                                    DiveParticipantsSection(
                                        participants: data.participants,
                                        isSaved: .constant(isCompleteSaved(index))
                                    ).onTapGesture {
                                        pageViewModel.activeInputSection = .participants
                                    }
                                    
                                    DiveEquipmentSection(
                                        equipment: data.equipment,
                                        isSaved: .constant(isCompleteSaved(index))
                                    ).onTapGesture {
                                        pageViewModel.activeInputSection = .equipment
                                    }
                                }
                                
                                DiveEnvironmentSection(
                                    environment: data.environment,
                                    isSaved: .constant(isCompleteSaved(index))
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .environment
                                }
                                
                                DiveProfileSection(
                                    profile: data.profile,
                                    isSaved: .constant(isCompleteSaved(index))
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .profile
                                }
                                
                                HStack {
                                    Spacer()
                                    // ✅ 서버에서 받은 이 다이빙 횟수 사용
                                    Text("이 다이빙 횟수 \(mainViewModel.totalDiveCount) 회")
                                        .font(Font.omyu.regular(size: 24))
                                    Spacer()
                                }
                                
                                PageIndicatorView(
                                    numberOfPages: mainViewModel.diveLogData.count,
                                    currentPage: pageViewModel.selectedPage
                                )
                            }
                            .padding()
                        }
                    }
                    .ignoresSafeArea()
                    // 슬라이드 제스처 추가
                    .gesture(
                        DragGesture(minimumDistance: 50)
                            .onEnded { value in
                                // 왼쪽으로 슬라이드 (마지막 페이지에서)
                                if value.translation.width < -50 &&
                                    index == mainViewModel.diveLogData.count - 1 {
                                    handleAddNewLog()
                                }
                            }
                    )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // DiveInputPageView 팝업
            if let section = pageViewModel.activeInputSection {
                GeometryReader { geometry in
                    // 흐린 배경
                    Color.white.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // 닫기 버튼
                        HStack {
                            Spacer()
                            Button(action: {
                                pageViewModel.handleCloseButtonTap()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20))
                                    .padding()
                            }
                        }
                        
                        // DiveInputPageView 팝업
                        DiveInputPageView(
                            initialPage: section.rawValue,
                            overview: Binding(
                                get: { mainViewModel.diveLogData[pageViewModel.selectedPage].overview ?? DiveOverview() },
                                set: { mainViewModel.diveLogData[pageViewModel.selectedPage].overview = $0 }
                            ),
                            participants: Binding(
                                get: { mainViewModel.diveLogData[pageViewModel.selectedPage].participants ?? DiveParticipants() },
                                set: { mainViewModel.diveLogData[pageViewModel.selectedPage].participants = $0 }
                            ),
                            equipment: Binding(
                                get: { mainViewModel.diveLogData[pageViewModel.selectedPage].equipment ?? DiveEquipment() },
                                set: { mainViewModel.diveLogData[pageViewModel.selectedPage].equipment = $0 }
                            ),
                            environment: Binding(
                                get: { mainViewModel.diveLogData[pageViewModel.selectedPage].environment ?? DiveEnvironment() },
                                set: { mainViewModel.diveLogData[pageViewModel.selectedPage].environment = $0 }
                            ),
                            profile: Binding(
                                get: { mainViewModel.diveLogData[pageViewModel.selectedPage].profile ?? DiveProfile() },
                                set: { mainViewModel.diveLogData[pageViewModel.selectedPage].profile = $0 }
                            )
                        )
                        .frame(
                            width: geometry.size.width * 0.9,
                            height: geometry.size.height * 0.7
                        )
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                    .zIndex(10)
                }
            }
            
            // TempPop 팝업 (alert 대신 사용)
            if pageViewModel.showUnsavedAlert {
                
                GeometryReader { geometry in
                    Color.white.opacity(0.8)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        
                        TempPop(
                            onTempSave: {
                                pageViewModel.handleTempSave()
                                pageViewModel.showUnsavedAlert = false
                            },
                            onDiscardChanges: {
                                pageViewModel.handleDiscardChanges()
                                pageViewModel.showUnsavedAlert = false
                            },
                            onClose: {
                                pageViewModel.showUnsavedAlert = false
                            }
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }
            }
            
            // NewLogPop 팝업
            if showNewLogPop {
                NewLogPop(
                    isPresented: $showNewLogPop,
                    title: .constant(""),
                    onCancel: {
                        showNewLogPop = false
                    },
                    onAddNewLog: {
                        // 새 로그 추가 로직
                        mainViewModel.addNewLogBook { success in
                            showNewLogPop = false
                            if success {
                                // 새로 추가된 로그로 이동
                                pageViewModel.selectedPage = mainViewModel.diveLogData.count - 1
                            }
                        }
                    }
                )
                .zIndex(25)
            }
            
            // 임시저장 완료 메시지
            if pageViewModel.showTempSavedMessage {
                VStack {
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 12) {
                        Spacer()
                        
                        Text("임시저장 완료!")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 16))
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                    }
                    .frame(width: 350, alignment: .center)
                    .background(Color.grayscale_g500)
                    .cornerRadius(8)
                    .transition(.opacity)
                }
                .zIndex(30)
            }
            
            // 최대 로그 개수 초과 에러 팝업
            if showMaxLogError {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Text("최대 3개까지만\n추가할 수 있습니다")
                            .font(Font.omyu.regular(size: 20))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Button("확인") {
                            showMaxLogError = false
                        }
                        .font(Font.omyu.regular(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primary_sea_blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 40)
                }
                .zIndex(35)
            }
        }
    }
    
    // ✅ 완전저장 상태 확인 메서드 추가
    private func isCompleteSaved(_ index: Int) -> Bool {
        guard index < mainViewModel.diveLogData.count else { return false }
        return mainViewModel.diveLogData[index].saveStatus == .complete
    }
    
    // 새 로그 추가 처리
    private func handleAddNewLog() {
        if mainViewModel.diveLogData.count >= 3 {
            showMaxLogError = true
        } else {
            showNewLogPop = true
        }
    }
}

#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}
