//
//  OceanCatalogService.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Combine
import Moya
import CombineMoya

final class OceanCatalogService {
    private let provider = MoyaProvider<OceanCatalogAPI>()
    
    func getCardList(type: String?) -> AnyPublisher<[CreatureCardEntity], Error> {
        return provider.requestPublisher(.getCardList(type: type))
            .handleEvents(receiveOutput: { response in
                print("getCardList \(String(describing: type)) response:", response)
            })
            .eraseToAnyPublisher()
            .extractData([CreatureCardDTO].self)
            .map({ $0.map(\.entity) })
            .manageThread()
    }
    
    func getCardDetail(id: Int) -> AnyPublisher<CreatureCardEntity, Error> {
        return provider.requestPublisher(.getCardDetail(cardId: id))
            .handleEvents(receiveOutput: { response in
                print("getCardDetail response:", response)
            })
            .eraseToAnyPublisher()
            .extractData(CreatureCardDTO.self)
            .map({ $0.entity })
            .manageThread()
    }
}
