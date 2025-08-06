//
//  LogBookPageView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI
import Foundation

struct LogBookPageView: View {
    @Bindable var viewModel: LogBookMainViewModel
    @State var selectedPage: Int = 0
    @State var isSaved: Bool = false
    @State private var activeInputSection: InputSectionType? = nil
    
    // 임시저장 관련 상태 추가
       @State private var showUnsavedAlert = false
       @State private var showTempSavedMessage = false
    
    var body: some View {
        ZStack{
            TabView(selection: $selectedPage) {
                ForEach(Array(viewModel.diveLogData.enumerated()), id: \.offset) { index, _ in
                    let data = $viewModel.diveLogData[index]
                    
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
                                Text(viewModel.logBaseTitle)
                                    .font(Font.omyu.regular(size: 20))
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                
                                DiveOverviewSection(overview: data.overview, isSaved: $isSaved).onTapGesture {
                                    activeInputSection = .overview
                                }
                                HStack(alignment: .top) {
                                    DiveParticipantsSection(participants: data.participants, isSaved: $isSaved).onTapGesture {
                                        activeInputSection = .participants
                                    }
                                    DiveEquipmentSection(equipment: data.equipment, isSaved: $isSaved).onTapGesture {
                                        activeInputSection = .equipment
                                    }
                                }
                                DiveEnvironmentSection(environment: data.environment, isSaved: $isSaved).onTapGesture {
                                    activeInputSection = .environment
                                }
                                DiveProfileSection(profile: data.profile, isSaved: $isSaved).onTapGesture {
                                    activeInputSection = .profile
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("총 다이빙 횟수 \(viewModel.logCount) 회")
                                        .font(Font.omyu.regular(size: 24))
                                    Spacer()
                                }
                                
                                PageIndicatorView(
                                    numberOfPages: viewModel.diveLogData.count,
                                    currentPage: selectedPage
                                )
                            }
                            .padding()
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            if let section = activeInputSection {
                    GeometryReader { geometry in
                        // 흐린 배경
                        Color.white.opacity(0.8)
                            .ignoresSafeArea()

                        VStack(spacing: 0) {
                            // 닫기 버튼
                                                HStack {
                                                    Spacer()
                                                    Button(action: {
                                                        handleCloseButtonTap()
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
                                    get: { viewModel.diveLogData[selectedPage].overview ?? DiveOverview() },
                                    set: { viewModel.diveLogData[selectedPage].overview = $0 }
                                ),
                                participants: Binding(
                                    get: { viewModel.diveLogData[selectedPage].participants ?? DiveParticipants() },
                                    set: { viewModel.diveLogData[selectedPage].participants = $0 }
                                ),
                                equipment: Binding(
                                    get: { viewModel.diveLogData[selectedPage].equipment ?? DiveEquipment() },
                                    set: { viewModel.diveLogData[selectedPage].equipment = $0 }
                                ),
                                environment: Binding(
                                    get: { viewModel.diveLogData[selectedPage].environment ?? DiveEnvironment() },
                                    set: { viewModel.diveLogData[selectedPage].environment = $0 }
                                ),
                                profile: Binding(
                                    get: { viewModel.diveLogData[selectedPage].profile ?? DiveProfile() },
                                    set: { viewModel.diveLogData[selectedPage].profile = $0 }
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
                 if showTempSavedMessage {
                     VStack {
                         Spacer()
                         Text("임시저장 완료")
                             .font(Font.omyu.regular(size: 16))
                             .foregroundColor(.white)
                             .padding()
                             .background(Color.black.opacity(0.7))
                             .cornerRadius(8)
                             .transition(.opacity)
                         Spacer()
                     }
                     .zIndex(20)
                 }
             }
             .alert("아직 작성되지 않은 내용이 있어요", isPresented: $showUnsavedAlert) {
                 Button("임시저장하고 나가기") {
                     handleTempSave()
                 }
                 Button("그냥 나가기") {
                     handleDiscardChanges()
                 }
             } message: {
                 Text("저장하지 않으면 지금까지 입력한 내용이 사라집니다")
             }
         }
         
         // X 버튼 클릭 처리
         private func handleCloseButtonTap() {
             // 1. 임시저장 상태이고 변경사항이 없으면 그냥 닫기
             if viewModel.isTempSaved && !viewModel.hasChangesFromTempSave(for: selectedPage) {
                 withAnimation {
                     activeInputSection = nil
                 }
                 return
             }
             
             // 2. 모든 섹션이 완성되었으면 그냥 닫기
             if viewModel.areAllSectionsComplete(for: selectedPage) {
                 withAnimation {
                     activeInputSection = nil
                 }
             } else {
                 // 3. 미완성이고 변경사항이 있으면 알림 표시
                 showUnsavedAlert = true
             }
         }
         
         // 임시저장하고 나가기
         private func handleTempSave() {
             viewModel.tempSave()
             
             // 임시저장 완료 메시지 표시
             withAnimation {
                 showTempSavedMessage = true
                 activeInputSection = nil
             }
             
             // 2초 후 메시지 숨기기
             DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 withAnimation {
                     showTempSavedMessage = false
                 }
             }
         }
         
    // 그냥 나가기 (변경사항 버리기)
      private func handleDiscardChanges() {
          // 임시저장된 상태가 있으면 임시저장된 데이터로 되돌리기
          if viewModel.isTempSaved {
              viewModel.restoreFromTempSave(for: selectedPage)
          } else {
              // 임시저장이 없으면 모든 필드 초기화
              viewModel.clearAllFields(for: selectedPage)
          }
          
          withAnimation {
              activeInputSection = nil
          }
      }
    
    //==
        }



#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}

