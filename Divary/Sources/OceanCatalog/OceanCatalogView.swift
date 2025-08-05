//
//  OceanCatalogView.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI

struct OceanCatalogView: View {
    @State private var selectedCategory: SeaCreatureCategory = .all
    @State private var selectedCard: SeaCreatureCard? = nil
    @State private var selectedCreature: SeaCreatureDetail? = nil
    @State private var showDetailView: Bool = false
    
//    let selectedCreature = SeaCreatureDetail(
//        id: 2,
//        name: "갯민숭달팽이",
//        type: "연체동물",
//        size: "약 1.5~6cm",
//        appearPeriod: "봄, 가을에 주로 관찰",
//        place: "따뜻한 연안, 바위 틈",
//        imageUrls: [
//            URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Nudibranch_flabellina.jpg/640px-Nudibranch_flabellina.jpg")!
//        ],
//        appearance: Appearance(
//            body: "부드럽고 납작한 몸체",
//            colorCodes: ["#FFFFFF", "#FFD700", "#000000"],
//            color: "흰색, 노란색, 검정색 점",
//            pattern: "누디브랜치",
//            etc: "촉수가 눈처럼 보임"
//        ),
//        personality: Personality(
//            activity: "느림",
//            socialSkill: "혼자 다님",
//            behavior: "서식지 주변을 기어다님",
//            reactivity: "자극에 민감"
//        ),
//        significant: Significant(
//            toxicity: "무독성",
//            strategy: "위장",
//            observeTip: "작고 조용히 숨어 있으니 자세히 봐야 함",
//            otherFeature: "바다 속 꽃처럼 생김"
//        )
//    )
    
    private let allItems: [SeaCreatureCard] = [
        SeaCreatureCard(id: 1, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 2, name: "갯민숭달팽이", type: "크크", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 3, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 4, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 5, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 6, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 7, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 8, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 9, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 10, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 11, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 12, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!)
    ]
    
    var filteredItems: [SeaCreatureCard] {
        switch selectedCategory {
        case .all:
            return allItems
        case .other:
            let excluded = ["어류", "갑각류", "연체동물"]
            return allItems.filter { !excluded.contains($0.type) }
        default:
            return allItems.filter { $0.type == selectedCategory.rawValue }
        }
}
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                CategoryTabBar(selectedCategory: $selectedCategory)
//                CardGridView(items: filteredItems)
                CardGridView(
                    items: filteredItems,
                    selectedCard: $selectedCard,
                    onSelect: { card in
                        fetchCreatureDetail(for: card)
                    }
                )
            }
        }
        .sheet(item: $selectedCreature, onDismiss: {
            selectedCard = nil
        }) { creature in
            BottomPreviewSheet(
                creature: creature,
                onDetailTapped: {
                    showDetailView = true
                }
            )
            .presentationDetents([.fraction(0.45)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func fetchCreatureDetail(for card: SeaCreatureCard) {
       // 이 부분은 실제 데이터 로딩 로직으로 대체 가능
       selectedCreature = SeaCreatureDetail.mock(for: card)
   }
}

#Preview {
    OceanCatalogView()
}
