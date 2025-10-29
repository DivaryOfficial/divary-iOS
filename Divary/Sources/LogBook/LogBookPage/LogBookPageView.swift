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
    
    // ✅ 제목 클릭 콜백
    var onTitleTap: (() -> Void)? = nil
    
    // ✅ init 수정 - onPageChanged 제거
    init(viewModel: LogBookMainViewModel, onTitleTap: (() -> Void)? = nil) {
        self._mainViewModel = Bindable(viewModel)
        self._pageViewModel = State(initialValue: LogBookPageViewModel(mainViewModel: viewModel))
        self.onTitleTap = onTitleTap
    }
    
    var body: some View {
        ZStack{
            // ✅ TabView 제거, 단일 ScrollView로 변경
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
                        // ✅ 제목 버튼
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

                        // ✅ 단일 로그북 데이터 바인딩
                        DiveOverviewSection(
                            overview: $mainViewModel.diveLogData.overview,
                            isSaved: .constant(mainViewModel.diveLogData.saveStatus == .complete)
                        ).onTapGesture {
                            pageViewModel.activeInputSection = .overview
                        }
                        
                        HStack(alignment: .top) {
                            DiveParticipantsSection(
                                participants: $mainViewModel.diveLogData.participants,
                                isSaved: .constant(mainViewModel.diveLogData.saveStatus == .complete)
                            ).onTapGesture {
                                pageViewModel.activeInputSection = .participants
                            }
                            
                            DiveEquipmentSection(
                                equipment: $mainViewModel.diveLogData.equipment,
                                isSaved: .constant(mainViewModel.diveLogData.saveStatus == .complete)
                            ).onTapGesture {
                                pageViewModel.activeInputSection = .equipment
                            }
                        }
                        
                        DiveEnvironmentSection(
                            environment: $mainViewModel.diveLogData.environment,
                            isSaved: .constant(mainViewModel.diveLogData.saveStatus == .complete)
                        ).onTapGesture {
                            pageViewModel.activeInputSection = .environment
                        }
                        
                        DiveProfileSection(
                            profile: $mainViewModel.diveLogData.profile,
                            isSaved: .constant(mainViewModel.diveLogData.saveStatus == .complete)
                        ).onTapGesture {
                            pageViewModel.activeInputSection = .profile
                        }
                        
                        HStack {
                            Spacer()
                            // ✅ 서버에서 받은 총 다이빙 횟수 사용
                            Text("이 다이빙 횟수 \(mainViewModel.totalDiveCount) 회")
                                .font(Font.omyu.regular(size: 24))
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
            .ignoresSafeArea()
            
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
                                get: { mainViewModel.diveLogData.overview ?? DiveOverview() },
                                set: { mainViewModel.diveLogData.overview = $0 }
                            ),
                            participants: Binding(
                                get: { mainViewModel.diveLogData.participants ?? DiveParticipants() },
                                set: { mainViewModel.diveLogData.participants = $0 }
                            ),
                            equipment: Binding(
                                get: { mainViewModel.diveLogData.equipment ?? DiveEquipment() },
                                set: { mainViewModel.diveLogData.equipment = $0 }
                            ),
                            environment: Binding(
                                get: { mainViewModel.diveLogData.environment ?? DiveEnvironment() },
                                set: { mainViewModel.diveLogData.environment = $0 }
                            ),
                            profile: Binding(
                                get: { mainViewModel.diveLogData.profile ?? DiveProfile() },
                                set: { mainViewModel.diveLogData.profile = $0 }
                            )
                        )
                        .frame(
                            width: geometry.size.width * 0.9,
                            height: geometry.size.height * 0.7
                        )
                        .cornerRadius(20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                    .zIndex(10)
                }
            }
            
            // TempPop 팝업
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
