//
//  TokenInterceptor.swift
//  Divary
//
//  Created by 송재곤 on 9/17/25.
//

import Foundation
import Alamofire
import Moya

final class TokenInterceptor: RequestInterceptor {
    
    private let tokenManager: TokenManager
    struct EmptyData: Codable {}
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    // 요청을 보내기 직전에 헤더 추가
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }
    
    // 요청 실패 시 토큰 만료 여부 확인 후 재시도
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if let data = request.request?.httpBody {
            do {
                let errorResponse = try JSONDecoder().decode(DefaultResponse<EmptyData>.self, from: data)
                
                // 2. 서버가 보낸 코드가 "AUTH_002"가 아니면 재시도하지 않음
                guard errorResponse.code == "AUTH_002" else {
                    completion(.doNotRetryWithError(error))
                    return
                }
            } catch {
                // 에러 응답 디코딩 실패 시 재시도하지 않음
                completion(.doNotRetryWithError(error))
                return
            }
            
            // 재발급 API 요청에서 401이 발생하면 무한 루프 방지
            if let url = request.request?.url?.absoluteString, url.contains("/api/v1/auth/reissue") {
                completion(.doNotRetryWithError(error))
                return
            }
            
            tokenManager.refreshToken { didRefresh in
                if didRefresh {
                    completion(.retry)
                } else {
                    completion(.doNotRetry)
                }
            }
        }
    }
}
