//
//  AnyPublisher+Ext.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Combine
import CombineMoya
import Moya

extension AnyPublisher where Output == Response, Failure == MoyaError {
    func extractData<D: Codable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> AnyPublisher<D, Error> {
        return map(DefaultResponse<D>.self)
            .tryMap({ defaultResponse in
                switch defaultResponse.status {
                case 200..<300:
                    guard let data = defaultResponse.data else {
                        throw APIError.resultNil
                    }
                    return data
                case 300..<400:
                    throw APIError.responseState(status: defaultResponse.status, code: defaultResponse.code, message: defaultResponse.message)
                case 400..<500:
                    throw APIError.responseState(status: defaultResponse.status, code: defaultResponse.code, message: defaultResponse.message)
                case 500..<600:
                    throw APIError.responseState(status: defaultResponse.status, code: defaultResponse.code, message: defaultResponse.message)
                default:
                    throw APIError.responseState(status: defaultResponse.status, code: defaultResponse.code, message: defaultResponse.message)
                }
            })
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
}
