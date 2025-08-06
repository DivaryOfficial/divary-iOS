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
    
    // init에서 pageViewModel 초기화
    init(viewModel: LogBookMainViewModel) {
        self._mainViewModel = Bindable(viewModel)
        self._pageViewModel = State(initialValue: LogBookPageViewModel(mainViewModel: viewModel))
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
                                Text(mainViewModel.logBaseTitle)
                                    .font(Font.omyu.regular(size: 20))
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                
                                DiveOverviewSection(overview: data.overview, isSaved: $pageViewModel.isSaved).onTapGesture {
                                    pageViewModel.activeInputSection = .overview
                                }
                                HStack(alignment: .top) {
                                    DiveParticipantsSection(participants: data.participants, isSaved: $pageViewModel.isSaved).onTapGesture {
                                        pageViewModel.activeInputSection = .participants
                                    }
                                    DiveEquipmentSection(equipment: data.equipment, isSaved: $pageViewModel.isSaved).onTapGesture {
                                        pageViewModel.activeInputSection = .equipment
                                    }
                                }
                                DiveEnvironmentSection(environment: data.environment, isSaved: $pageViewModel.isSaved).onTapGesture {
                                    pageViewModel.activeInputSection = .environment
                                }
                                DiveProfileSection(profile: data.profile, isSaved: $pageViewModel.isSaved).onTapGesture {
                                    pageViewModel.activeInputSection = .profile
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("총 다이빙 횟수 \(mainViewModel.logCount) 회")
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
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
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
            
            // 임시저장 완료 메시지
            if pageViewModel.showTempSavedMessage {
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
                .zIndex(20)
            }
        }
        .alert("아직 작성되지 않은 내용이 있어요", isPresented: $pageViewModel.showUnsavedAlert) {
            Button("임시저장하고 나가기") {
                pageViewModel.handleTempSave()
            }
            Button("그냥 나가기") {
                pageViewModel.handleDiscardChanges()
            }
        } message: {
            Text("저장하지 않으면 지금까지 입력한 내용이 사라집니다")
        }
    }
}

#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}
