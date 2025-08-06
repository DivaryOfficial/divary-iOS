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
    
    var creatureCards: [CreatureCardEntity] = []
    
    func getCardList(type: String) {
        service.getCardList(type: type)
            .sinkHandledCompletion(receiveValue: { [weak self] creatureCardEntities in
                self?.creatureCards = creatureCardEntities
            })
            .store(in: &cancellable)
    }
}
