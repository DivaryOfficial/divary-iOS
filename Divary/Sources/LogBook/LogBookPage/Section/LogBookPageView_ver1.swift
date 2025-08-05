//  LogBookPageView.swift
//  Divary

import SwiftUI
import Foundation

struct LogBookPageView: View {
    @Bindable var viewModel: LogBookMainViewModel
    @State var selectedPage: Int = 0
    @State var isSaved: Bool = false
    @State private var activeInputSection: InputSectionType? = nil

    var body: some View {
        ZStack {
            TabView(selection: $selectedPage) {
                ForEach(Array(viewModel.logsForSelectedDate.enumerated()), id: \ .offset) { index, log in
                    Group {
                        if let realIndex = viewModel.diveLogData.firstIndex(where: { $0 === log }) {
                            let data = $viewModel.diveLogData[realIndex]

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
                                        Text(data.title.isEmpty ? "제목 없음" : data.title)
                                            .font(Font.omyu.regular(size: 20))
                                            .padding(12)
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)

                                        DiveOverviewSection(overview: data.overview, isSaved: $isSaved)
                                            .onTapGesture { activeInputSection = .overview }

                                        HStack(alignment: .top) {
                                            DiveParticipantsSection(participants: data.participants, isSaved: $isSaved)
                                                .onTapGesture { activeInputSection = .participants }
                                            DiveEquipmentSection(equipment: data.equipment, isSaved: $isSaved)
                                                .onTapGesture { activeInputSection = .equipment }
                                        }

                                        DiveEnvironmentSection(environment: data.environment, isSaved: $isSaved)
                                            .onTapGesture { activeInputSection = .environment }

                                        DiveProfileSection(profile: data.profile, isSaved: $isSaved)
                                            .onTapGesture { activeInputSection = .profile }

                                        HStack {
                                            Spacer()
                                            Text("총 다이빙 횟수 \(viewModel.logCount) 회")
                                                .font(Font.omyu.regular(size: 24))
                                            Spacer()
                                        }

                                        PageIndicatorView(
                                            numberOfPages: viewModel.logsForSelectedDate.count,
                                            currentPage: selectedPage
                                        )
                                    }
                                    .padding()
                                }
                            }
                            .ignoresSafeArea()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            if let section = activeInputSection {
                GeometryReader { geometry in
                    Color.white.opacity(0.8)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
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

                        if let log = viewModel.logsForSelectedDate[safe: selectedPage],
                           let realIndex = viewModel.diveLogData.firstIndex(where: { $0 === log }) {

                            DiveInputPageView(
                                initialPage: section.rawValue,
                                overview: Binding(
                                    get: { viewModel.diveLogData[realIndex].overview ?? DiveOverview() },
                                    set: { viewModel.diveLogData[realIndex].overview = $0 }
                                ),
                                participants: Binding(
                                    get: { viewModel.diveLogData[realIndex].participants ?? DiveParticipants() },
                                    set: { viewModel.diveLogData[realIndex].participants = $0 }
                                ),
                                equipment: Binding(
                                    get: { viewModel.diveLogData[realIndex].equipment ?? DiveEquipment() },
                                    set: { viewModel.diveLogData[realIndex].equipment = $0 }
                                ),
                                environment: Binding(
                                    get: { viewModel.diveLogData[realIndex].environment ?? DiveEnvironment() },
                                    set: { viewModel.diveLogData[realIndex].environment = $0 }
                                ),
                                profile: Binding(
                                    get: { viewModel.diveLogData[realIndex].profile ?? DiveProfile() },
                                    set: { viewModel.diveLogData[realIndex].profile = $0 }
                                )
                            )
                            .frame(
                                width: geometry.size.width * 0.9,
                                height: geometry.size.height * 0.7
                            )
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        }
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

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.date(from: "2025-08-01")!
    let vm = LogBookMainViewModel(selectedDate: date)
    return LogBookPageView(viewModel: vm)
}
