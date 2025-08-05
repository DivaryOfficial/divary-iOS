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
                                    withAnimation {
                                        activeInputSection = nil
                                    }
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
        }
    }
}




#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}

