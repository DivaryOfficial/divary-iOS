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

