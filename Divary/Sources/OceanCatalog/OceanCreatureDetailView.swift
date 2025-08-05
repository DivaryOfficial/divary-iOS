//
//  OceanCreatureDetailView.swift
//  Divary
//
//  Created by 김나영 on 8/5/25.
//

import SwiftUI

struct OceanCreatureDetailView: View {
    let creature: SeaCreatureDetail

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: creature.imageUrls.first) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray
                    }
                }
                .frame(height: 220)
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(creature.name) (\(creature.appearance.pattern))")
                        .font(.omyu.regular(size: 24))
                    Text(creature.type)
                        .font(.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                        .foregroundColor(.gray)

                    VStack {
                        DetailInfoBlock(title: "크기", value: creature.size)
                            .padding(.horizontal)
                            .padding(.top)
                        DetailInfoBlock(title: "출몰시기", value: creature.appearPeriod)
                            .padding(.horizontal)
                        DetailInfoBlock(title: "서식", value: creature.place)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .background(Color(.grayscaleG100))
                    .cornerRadius(8)
//                    .padding(.vertical)
                }
                .padding()

                Group {
                    SectionHeader(title: "외모")
                    DetailLine("몸 형태", creature.appearance.body)
                    DetailLine("색상", creature.appearance.color)
                    DetailLine("무늬", creature.appearance.pattern)
                    DetailLine("기타", creature.appearance.etc)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                Divider()
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)
                    .background(Color(.grayscaleG200))
                        
                Group {
                    SectionHeader(title: "성격")
                    DetailLine("활동성", creature.personality.activity)
                    DetailLine("사회성", creature.personality.socialSkill)
                    DetailLine("행동 특성", creature.personality.behavior)
                    DetailLine("반응성", creature.personality.reactivity)
                }
                .padding(.horizontal)
                
                Divider()
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)
                    .background(Color(.grayscaleG200))
                
                Group {
                    SectionHeader(title: "특이사항")
                    DetailLine("독성", creature.significant.toxicity)
                    DetailLine("생존 전략", creature.significant.strategy)
                    DetailLine("관찰 팁", creature.significant.observeTip)
                    DetailLine("기타", creature.significant.otherFeature)
                }
                .padding(.horizontal)
                
            }
        }
        .navigationTitle("해양도감")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailInfoBlock: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).font(.NanumSquareNeo.NanumSquareNeoBold(size: 12)).foregroundColor(Color(.grayscaleG600))
            Spacer()
            Text(value).font(.NanumSquareNeo.NanumSquareNeoBold(size: 12)).foregroundColor(Color(.grayscaleG800))
        }
        .padding(.vertical, 4)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.omyu.regular(size: 24))
            .padding(.top, 16)
    }
}

func DetailLine(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title).font(.omyu.regular(size: 20))
            .padding(.bottom, 4)
        Text(value).font(.NanumSquareNeo.NanumSquareNeoBold(size: 14)).foregroundColor(Color(.grayscaleG700))
    }
}


#Preview {
    let sampleSeaCreatureDetail = SeaCreatureDetail(
        id: 2,
        name: "갯민숭달팽이",
        type: "연체동물",
        size: "약 1.5~6cm",
        appearPeriod: "봄, 가을에 주로 관찰",
        place: "따뜻한 연안, 바위 틈",
        imageUrls: [
            URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Nudibranch_flabellina.jpg/640px-Nudibranch_flabellina.jpg")!
        ],
        appearance: Appearance(
            body: "부드럽고 납작한 몸체",
            colorCodes: ["#FFFFFF", "#FFD700", "#000000"],
            color: "흰색, 노란색, 검정색 점",
            pattern: "누디브랜치",
            etc: "촉수가 눈처럼 보임"
        ),
        personality: Personality(
            activity: "느림",
            socialSkill: "혼자 다님",
            behavior: "서식지 주변을 기어다님",
            reactivity: "자극에 민감"
        ),
        significant: Significant(
            toxicity: "무독성",
            strategy: "위장",
            observeTip: "작고 조용히 숨어 있으니 자세히 봐야 함",
            otherFeature: "바다 속 꽃처럼 생김"
        )
    )
    
    OceanCreatureDetailView(creature: sampleSeaCreatureDetail)
}
