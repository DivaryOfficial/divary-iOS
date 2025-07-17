//
//  LogBookPageView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct LogBookPageView: View {
    @Bindable var viewModel: LogBookMainViewModel
    @State var selectedPage: Int = 0
    @State var isSaved: Bool = false
    
    
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(Array(viewModel.diveLogData.enumerated()), id: \.offset) { index, data in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        Image("gridBackground")
                            .resizable(resizingMode: .tile)
                            .ignoresSafeArea()

                        VStack(alignment: .leading, spacing: 18) {
                            Text("흰수염 고래 여름원정")
                                .font(Font.omyu.regular(size: 20))
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            DiveOverviewSection(overview: data.overview, isSaved: $isSaved)
                            HStack(alignment: .top) {
                                DiveParticipantsSection(participants: data.participants, isSaved: $isSaved)
                                DiveEquipmentSection(equipment: data.equipment, isSaved: $isSaved)
                            }
                            DiveEnvironmentSection(environment: data.environment, isSaved: $isSaved)
                            DiveProfileSection(profile: data.profile, isSaved: $isSaved)

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
    }
}




#Preview {
    let vm = LogBookMainViewModel()
    LogBookPageView(viewModel: vm)
}

