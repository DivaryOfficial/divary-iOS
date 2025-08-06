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
    @State private var detailCreature: SeaCreatureDetail? = nil
    @State private var navigateToDetail: Bool = false
    
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
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    CategoryTabBar(selectedCategory: $selectedCategory)
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
                        // push 할 데이터를 따로 보존
                        detailCreature = creature
                        
                        // 시트 닫기
                        selectedCreature = nil
                        
                        // 시트 닫은 뒤에 push
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToDetail = true
                        }
                    }
                )
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let creature = detailCreature {
                    OceanCreatureDetailView(creature: creature)
                }
            }
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
