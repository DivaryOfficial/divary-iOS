//
//  AuthService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

final class LoginService {
    private let provider = MoyaProvider<LoginAPI>()

    
    // 구글 로그인
    func googleLogin(accessToken: String, completion: @escaping (Result<LoginApiResponse, Error>) -> Void) {
        provider.request(.googleLogin(accessToken: accessToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 로그인 서버 응답: \(jsonString)")
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                print("❌ 로그인 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
