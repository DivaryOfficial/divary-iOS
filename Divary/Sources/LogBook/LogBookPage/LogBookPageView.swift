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
    
    // ✅ 추가: 현재 페이지 변경 콜백
    var onPageChanged: ((Int) -> Void)? = nil
    
    // NewLogPop 관련 상태
    @State private var showNewLogPop = false
    @State private var showMaxLogError = false
    
    // ✅ init 수정 - onPageChanged 파라미터 추가
    init(viewModel: LogBookMainViewModel, onTitleTap: (() -> Void)? = nil, onPageChanged: ((Int) -> Void)? = nil) {
        self._mainViewModel = Bindable(viewModel)
        self._pageViewModel = State(initialValue: LogBookPageViewModel(mainViewModel: viewModel))
        self.onTitleTap = onTitleTap
        self.onPageChanged = onPageChanged
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
                                        .foregroundStyle(.black)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                }

                                // ✅ 각 로그북별로 개별 완전저장 상태 전달
                                DiveOverviewSection(
                                    overview: data.overview,
                                    isSaved: .constant(mainViewModel.diveLogData[index].saveStatus == .complete)
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .overview
                                }
                                
                                HStack(alignment: .top) {
                                    DiveParticipantsSection(
                                        participants: data.participants,
                                        isSaved: .constant(mainViewModel.diveLogData[index].saveStatus == .complete)
                                    ).onTapGesture {
                                        pageViewModel.activeInputSection = .participants
                                    }
                                    
                                    DiveEquipmentSection(
                                        equipment: data.equipment,
                                        isSaved: .constant(mainViewModel.diveLogData[index].saveStatus == .complete)
                                    ).onTapGesture {
                                        pageViewModel.activeInputSection = .equipment
                                    }
                                }
                                
                                DiveEnvironmentSection(
                                    environment: data.environment,
                                    isSaved: .constant(mainViewModel.diveLogData[index].saveStatus == .complete)
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .environment
                                }
                                
                                DiveProfileSection(
                                    profile: data.profile,
                                    isSaved: .constant(mainViewModel.diveLogData[index].saveStatus == .complete)
                                ).onTapGesture {
                                    pageViewModel.activeInputSection = .profile
                                }
                                
                                HStack {
                                    Spacer()
                                    // ✅ 서버에서 받은 총 다이빙 횟수 사용
                                    Text("총 다이빙 횟수 \(mainViewModel.totalDiveCount) 회")
                                        .font(Font.omyu.regular(size: 24))
                                    Spacer()
                                }
                                
//                                PageIndicatorView(
//                                    numberOfPages: mainViewModel.diveLogData.count,
//                                    currentPage: pageViewModel.selectedPage
//                                )
                            }
                            .padding()
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // ✅ 제스처를 TabView 전체에 적용
            .simultaneousGesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        print("Debug - DragGesture 감지됨!")
                        print("Debug - selectedPage: \(pageViewModel.selectedPage)")
                        print("Debug - diveLogData.count: \(mainViewModel.diveLogData.count)")
                        print("Debug - translation.width: \(value.translation.width)")
                    }
            )
            // ✅ 페이지 변경 감지하여 상위로 전달
            .onChange(of: pageViewModel.selectedPage) { _, newPage in
                onPageChanged?(newPage)
            }
            
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
                        //.shadow(radius: 10)
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
            
            // 임시저장 완료 메시지
            if pageViewModel.showTempSavedMessage {
                VStack {
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 12) {
                        Spacer()
                        
                        Text("임시저장 완료!")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 16))
                            .foregroundStyle(.white)
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
            
        }
    }

}

#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}
