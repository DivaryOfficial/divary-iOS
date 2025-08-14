//
//  OceanCatalogView.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI

struct OceanCatalogView: View {
    @State private var viewModel = OceanCatalogViewModel()
    
    @State private var selectedCategory: SeaCreatureCategory = .all
    @State private var selectedCard: SeaCreatureCard?
    @State private var selectedCreature: SeaCreatureDetail?
    @State private var detailCreature: SeaCreatureDetail?
    @State private var navigateToDetail: Bool = false
    
    @State private var sheetVersion = 0
    
    var body: some View {
            ZStack(alignment: .bottom) {
                VStack {
                    CategoryTabBar(selectedCategory: Binding(
                        get: { viewModel.selectedCategory },
                        set: { viewModel.selectedCategory = $0 }
                    ))
                    
                    CardGridView(
                        items: viewModel.gridItems,
                        selectedCard: $selectedCard,
                        onSelect: { card in
                            if let entity = viewModel.creatureCards.first(where: { $0.id == card.id }) {
                                selectedCreature = SeaCreatureDetail.fromEntity(entity)
                            } else {
                                // 없어도 최소 정보로 시트 생성
                                selectedCreature = SeaCreatureDetail.fromEntity(
                                    CreatureCardEntity(id: card.id, name: card.name, type: card.type, dogamProfileUrl: card.imageUrl)
                                )
                            }
                            viewModel.getCardDetail(id: card.id)
                        }
                    )
                }
            }
            .onChange(of: viewModel.lastDetail) {
                guard let d = viewModel.lastDetail, let current = selectedCreature, d.id == current.id else { return }
                selectedCreature = d
                sheetVersion &+= 1
            }
            .sheet(item: $selectedCreature, onDismiss: {
                selectedCard = nil
            }) { creature in
                BottomPreviewSheet(
                    creature: creature,
                    onDetailTapped: {
                        detailCreature = creature // push 할 데이터를 따로 보존
                        selectedCreature = nil // 시트 닫기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // 시트 닫은 뒤에 push
                            navigateToDetail = true
                        }
                    }
                )
                .id(sheetVersion)
                .presentationDetents([.fraction(0.5)])
                .presentationSizing(.automatic)
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let creature = detailCreature {
                    OceanCreatureDetailView(creature: creature)
            }
        }
        .task {
            viewModel.onAppear()
        }
    }
}

#Preview {
    OceanCatalogView()
}
