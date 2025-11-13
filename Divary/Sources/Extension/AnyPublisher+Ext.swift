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
                    if let data = defaultResponse.data {
                        // 3a. data가 있으면 (프로필 조회 등) data를 그대로 반환
                        return data
                    } else {
                        // 3b. data가 nil이면 (레벨, 그룹 업데이트 등)
                        //     요청한 타입(D.self)이 EmptyData인지 확인
                        if D.self == EmptyData.self {
                            // EmptyData를 요청했고, data가 nil -> "성공"으로 간주
                            // 비어있는 EmptyData 인스턴스를 생성하여 성공으로 반환
                            return EmptyData() as! D
                        } else {
                            // 다른 타입(MemberProfileResponse 등)을 요청했는데 nil -> "실패"
                            throw APIError.resultNil
                        }
                    }
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
