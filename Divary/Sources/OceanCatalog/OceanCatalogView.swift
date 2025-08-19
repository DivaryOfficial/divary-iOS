//
//  OceanCatalogView.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI

struct OceanCatalogView: View {
    @Environment(\.diContainer) private var di
    
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
                Text("해양도감")
                    .font(Font.omyu.regular(size: 20))
                    .padding()
                CategoryTabBar(selectedCategory: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.selectedCategory = $0 }
                ))
                .padding(.bottom, 5)
                
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
        .overlay(alignment: .bottom) {
            if let creature = selectedCreature {
                BottomPreviewSheet(
                    creature: creature,
                    isPresented: .init(
                        get: { true },
                        set: { show in if !show { closePreview() } } // 배경탭/드래그로 닫힐 때 선택 해제
                    ),
                    onDetailTapped: {
                        closePreview()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            di.router.push(.oceanCreatureDetail(creature: creature)) // 이동
                        }
                    }
                )
                .id(sheetVersion) // detail 로딩 갱신용
            }
        }
        .task {
            viewModel.task()
        }
        .overlay {
            if viewModel.isLoadingList {
                LoadingOverlay(message: "로딩 중...")
            }
        }
    }
    
    private func closePreview() {
        withAnimation(.spring()) {
            selectedCreature = nil
            selectedCard = nil
        }
    }
}

#Preview {
    OceanCatalogView()
}
