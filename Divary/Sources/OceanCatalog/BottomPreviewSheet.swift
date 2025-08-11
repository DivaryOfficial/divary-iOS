//
//  BottomPreviewSheet.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI
import Kingfisher

struct BottomPreviewSheet: View {
    let creature: SeaCreatureDetail
    let onDetailTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(creature.name)")
                .font(.omyu.regular(size: 24))
                .bold()
            Text(creature.type)
                .foregroundStyle(Color(.grayscaleG600))
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 14))
            
            HStack(alignment: .center, spacing: 12) {
                if let url = creature.imageUrls.first {
                    KFImage(url)
                        .placeholder { ProgressView() }
                        .retry(maxCount: 2, interval: .seconds(1))
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: 260)
                        .id(url)
                } else {
                    Color.gray.opacity(0.2)
                        .frame(maxWidth: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    LabelledText(title: "크기", value: creature.size)
                    LabelledText(title: "출몰시기", value: creature.appearPeriod)
                    LabelledText(title: "서식", value: creature.place)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: nil) // 높이 제한 두지 않음
            
            Button(action: onDetailTapped) {
                Text("자세히보기")
                    .font(.omyu.regular(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .fixedSize(horizontal: false, vertical: false)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
//        .frame(maxHeight: 280) // 높이 제한
    }
}

private struct LabelledText: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                .foregroundStyle(Color(.grayscaleG600))
            Text(value)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 14))
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 13)
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
            URL(string: "")!
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
    
    return BottomPreviewSheet(
        creature: sampleSeaCreatureDetail,
        onDetailTapped: {
            print("자세히보기 버튼 눌림 (Preview용)")
        }
    )
}
