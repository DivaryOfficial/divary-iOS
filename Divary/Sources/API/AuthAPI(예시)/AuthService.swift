//
//  AuthService.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/8/25.
//

import Foundation
import Moya

// MARK: - AuthService

final class AuthService {

    static let shared = AuthService()

    private let provider = MoyaProvider<AuthAPI>()

    init() {}

    // MARK: - Kakao Login
    func kakaoLogin(accessToken: String, deviceId: String, deviceType: String, pushToken: String, appVersion: String, completion: @escaping (Result<KakaoResponseDTO, Error>) -> Void) {
        provider.request(.kakaoLogin(accessToken: accessToken, deviceId: deviceId, deviceType: deviceType, pushToken: pushToken, appVersion: appVersion)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Naver Login
    func naverLogin(accessToken: String, deviceId: String, deviceType: String, pushToken: String, appVersion: String, completion: @escaping (Result<NaverResponseDTO, Error>) -> Void) {
        provider.request(.naverLogin(accessToken: accessToken, deviceId: deviceId, deviceType: deviceType, pushToken: pushToken, appVersion: appVersion)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Refresh Token
    func refreshToken(refreshToken: String, completion: @escaping (Result<TokenResponseDTO, Error>) -> Void) {
        provider.request(.refreshToken(refreshToken: refreshToken)) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Test Nickname
    func testNickname(completion: @escaping (Result<NicknameResponseDTO, Error>) -> Void) {
        provider.request(.testNickname) { result in
            self.handleResponse(result, completion: completion)
        }
    }

    // MARK: - Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("서버 응답: \(jsonString)")
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                DebugLogger.error("디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
