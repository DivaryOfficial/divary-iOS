//
//  LogBookPageView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct LogBookPageView: View {
    
    var diveLogData: [DiveLogData]
    var logCount: Int {
        3 - diveLogData.filter { $0.isEmpty }.count
    }
    @State private var selectedPage: Int = 0
    
    
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(Array(diveLogData.enumerated()), id: \.offset) { index, data in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        Image("gridBackground")
                            .resizable(resizingMode: .tile)
                            .ignoresSafeArea()

                        VStack(alignment: .leading, spacing: 16) {
                            Text("흰수염 고래 여름원정")
                                .font(Font.omyu.regular(size: 20))
                                .padding(.top)
                                .frame(maxWidth: .infinity) // 수평 전체 차지
                                .multilineTextAlignment(.center)

                            DiveOverviewSection(overview: data.overview)
                            HStack {
                                DiveParticipantsSection(participants: data.participants)
                                DiveEquipmentSection(equipment: data.equipment)
                            }
                            DiveEnvironmentSection(environment: data.environment)
                            DiveProfileSection(profile: data.profile)

                            HStack {
                                Spacer()
                                Text("총 다이빙 횟수 \(logCount) 회")
                                    .font(Font.omyu.regular(size: 24))
                                Spacer()
                            }

                            PageIndicatorView(
                                numberOfPages: diveLogData.count,
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

        }
    }



#Preview {
    let defaultLog = DiveLogData(
        overview: nil,
        participants: nil,
        equipment: nil,
        environment: nil,
        profile: nil
    )
    var data: [DiveLogData] = Array(repeating: defaultLog, count: 3)
    
    LogBookPageView(diveLogData: LogBookPageMock)
        .ignoresSafeArea()
}
