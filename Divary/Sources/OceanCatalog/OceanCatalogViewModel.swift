//
//  OceanCatalogViewModel.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Combine

@Observable
class OceanCatalogViewModel {
    
    var service = OceanCatalogService()
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    var selectedCategory: SeaCreatureCategory = .all {
        didSet { fetchByCategory() } // 카테고리 바뀔 때 자동 호출
    }
    
    var creatureCards: [CreatureCardEntity] = []
    var creatureCardDetail: CreatureCardEntity?
    
    // MARK: - getCardList 함수들
    var gridItems: [SeaCreatureCard] {
        creatureCards.map {
            SeaCreatureCard(
                id: $0.id,
                name: $0.name,
                type: $0.type,
                imageUrl: $0.dogamProfileUrl ?? URL(string: "about:blank")!
            )
        }
    }
    
    func getCardList(type: String) {
        service.getCardList(type: type)
            .sinkHandledCompletion(receiveValue: { [weak self] creatureCardEntities in
                print(creatureCardEntities)
                self?.creatureCards = creatureCardEntities
            })
            .store(in: &cancellable)
    }
    
    // 최초 진입 시 호출
    func onAppear() {
        if creatureCards.isEmpty {
            fetchByCategory()
        }
    }

    // 카테고리별 호출
    func fetchByCategory() {
        let typeParam: String? = selectedCategory == .all ? nil : apiType(from: selectedCategory)
        service.getCardList(type: typeParam)
            .sinkHandledCompletion(receiveValue: { [weak self] list in
                self?.creatureCards = list
            })
            .store(in: &cancellable)
    }

    // 서버 규칙에 맞춘 type 매핑
    func apiType(from category: SeaCreatureCategory) -> String {
        switch category {
//        case .all:
//            return ""
        case .other:
            return "기타"
        default:
            return category.rawValue
        }
    }

    // 상세 미리보기(현재는 목업 예시 그대로)
    func buildPreview(for card: SeaCreatureCard) -> SeaCreatureDetail {
        SeaCreatureDetail.mock(for: card)
    }
    
    // MARK: - getCardDetail 함수들
    func getCardDetail(id: Int) {
        service.getCardDetail(id: id)
            .sinkHandledCompletion(receiveValue: { [weak self] entity in
                print("detail:", entity)
                self?.creatureCardDetail = entity
                if let index = self?.creatureCards.firstIndex(where: { $0.id == entity.id }) {
                    self?.creatureCards[index] = entity
                } else {
                    self?.creatureCards.append(entity)
                }
            })
            .store(in: &cancellable)
    }

}
