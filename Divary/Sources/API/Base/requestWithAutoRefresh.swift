//
//  requestWithAutoRefresh.swift
//  Divary
//
//  Created by 바견규 on 10/7/25.
//

import Foundation
import Moya
import Combine

// ---- 콜백 기반 (Result) ----
extension MoyaProvider where Target: TargetType {
    func requestWithAutoRefresh(
        makeTarget: @escaping () -> Target,
        completion: @escaping (Result<Response, MoyaError>) -> Void
    ) {
        self.request(makeTarget()) { first in
            switch first {
            case .success(let resp) where resp.statusCode == 401:
                guard let tm = TokenManagerRegistry.shared.manager else {
                    completion(first); return
                }
                tm.refreshIfNeededSerial { ok in
                    guard ok else {
                        completion(.failure(.underlying(NSError(domain: "reissue-failed", code: 0), nil)))
                        return
                    }
                    self.request(makeTarget(), completion: completion)
                }
            default:
                completion(first)
            }
        }
    }
}

// ---- 퍼블리셔 기반 (Combine) ----
extension MoyaProvider where Target: TargetType {
    func requestPublisherWithAutoRefresh(
        makeTarget: @escaping () -> Target
    ) -> AnyPublisher<Response, MoyaError> {
        self.requestPublisher(makeTarget())
            .catch { err -> AnyPublisher<Response, MoyaError> in
                if case let .statusCode(resp) = err, resp.statusCode == 401,
                   let tm = TokenManagerRegistry.shared.manager {
                    return Future<Response, MoyaError> { promise in
                        tm.refreshIfNeededSerial { ok in
                            guard ok else {
                                promise(.failure(.underlying(NSError(domain: "reissue-failed", code: 0), nil)))
                                return
                            }
                            self.request(makeTarget()) { second in
                                switch second {
                                case .success(let response): promise(.success(response))
                                case .failure(let e):       promise(.failure(e))
                                }
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                return Fail(error: err).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
