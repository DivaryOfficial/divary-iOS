//
//  DivelogpageView.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//


import SwiftUI

struct DiveLogPageView: View {
    @Binding var data: DiveLogData
    @Binding var isSaved: Bool
    @Binding var activeInputSection: InputSectionType?


    var body: some View {
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
                }
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    @State var isSaved = false
    @State var section: InputSectionType? = nil
    @State var log = DiveLogData(
        title: "프리뷰 로그",
        date: "2025-08-01",
        overview: DiveOverview(title: "제주 문섬", point: "동굴", purpose: "자율", method: "보트"),
        participants: DiveParticipants(leader: "리더", buddy: "버디", companion: ["A", "B"]),
        equipment: DiveEquipment(suitType: "5mm", Equipment: ["마스크"], weight: 5, pweight: "적당"),
        environment: DiveEnvironment(weather: "맑음", wind: "약함", current: "없음", wave: "작음", airTemp: 25, feelsLike: "시원함", waterTemp: 22, visibility: "좋음"),
        profile: DiveProfile(diveTime: 40, maxDepth: 18, avgDepth: 12, decoStop: 0, startPressure: 200, endPressure: 50)
    )

    return DiveLogPageView(data: $log, isSaved: $isSaved, activeInputSection: $section)
}
