//
//  DiveInputPageView.swift
//  Divary
//
//  Created by chohaeun on 7/22/25.
//

import SwiftUI

struct DiveInputPageView: View {
    @State private var selectedPage: Int

    @Binding var overview: DiveOverview
    @Binding var participants: DiveParticipants
    @Binding var equipment: DiveEquipment
    @Binding var environment: DiveEnvironment
    @Binding var profile: DiveProfile

    init(
        initialPage: Int,
        overview: Binding<DiveOverview>,
        participants: Binding<DiveParticipants>,
        equipment: Binding<DiveEquipment>,
        environment: Binding<DiveEnvironment>,
        profile: Binding<DiveProfile>
    ) {
        self._selectedPage = State(initialValue: initialPage)
        self._overview = overview
        self._participants = participants
        self._equipment = equipment
        self._environment = environment
        self._profile = profile
    }

    var body: some View {
        let pages: [AnyView] = [
            AnyView(OverViewInputView(overview: $overview)),
            AnyView(ParticipantsInputView(participants: $participants)),
            AnyView(EquipmentInputView(equipment: $equipment)),
            AnyView(EnvironmentInputView(environment: $environment)),
            AnyView(ProfileInputView(profile: $profile))
        ]

        VStack {
            TabView(selection: $selectedPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    ScrollView {
                        VStack(alignment:.center) {
                            pages[index]
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            PageIndicatorView(
                numberOfPages: pages.count,
                currentPage: selectedPage
            )
        }
    }
}


//#Preview {
//    @Previewable @State var overview = DiveOverview(
//        title: "제주 서귀포",
//        point: "문섬",
//        purpose: "펀 다이빙",
//        method: "보트"
//    )
//    @Previewable @State var participants = DiveParticipants(
//        leader: "이예나",
//        buddy: "지안",
//        companion: ["하람", "주원"]
//    )
//    @Previewable @State var equipment = DiveEquipment(
//        suitType: "드라이슈트",
//        Equipment: ["BCD", "레귤레이터"],
//        weight: 5,
//        pweight: "약간 무거움"
//    )
//    @Previewable @State var environment = DiveEnvironment(
//        weather: "맑음",
//        wind: "약풍",
//        current: "약함",
//        wave: "보통",
//        airTemp: 24,
//        waterTemp: 18,
//        visibility: "좋음"
//    )
//    @Previewable @State var profile = DiveProfile(
//        diveTime: 35,
//        maxDepth: 18,
//        avgDepth: 12,
//        decoStop: 0,
//        startPressure: 200,
//        endPressure: 60
//    )
//
//    return DiveInputPageView(
//        initialPage: 0,
//        overview: $overview,
//        participants: $participants,
//        equipment: $equipment,
//        environment: $environment,
//        profile: $profile
//    )
//}

