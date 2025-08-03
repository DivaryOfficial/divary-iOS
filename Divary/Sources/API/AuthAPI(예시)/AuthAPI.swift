//
//  AuthAPI.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation
import Moya

enum AuthAPI {
    case kakaoLogin(accessToken: String, deviceId: String, deviceType: String, pushToken: String, appVersion: String)
    case naverLogin(accessToken: String, deviceId: String, deviceType: String, pushToken: String, appVersion: String)
    case refreshToken(refreshToken: String)
    case testNickname
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .kakaoLogin:
            return "/api/auth/kakao"
        case .naverLogin:
            return "/api/auth/naver"
        case .refreshToken:
            return "/api/auth/refresh"
        case .testNickname:
            return "/api/auth/test-nickname"
        }
    }

    var method: Moya.Method {
        switch self {
        case .kakaoLogin, .naverLogin, .refreshToken:
            return .post
        case .testNickname:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .kakaoLogin(accessToken, deviceId, deviceType, pushToken, appVersion),
             let .naverLogin(accessToken, deviceId, deviceType, pushToken, appVersion):
            let params: [String: Any] = [
                "accessToken": accessToken,
                "deviceId": deviceId,
                "deviceType": deviceType,
                "pushToken": pushToken,
                "appVersion": appVersion
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .refreshToken(refreshToken):
            let params: [String: Any] = ["refreshToken": refreshToken]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .testNickname:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var baseHeaders: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]

        switch self {
        case .kakaoLogin, .naverLogin, .refreshToken:
            baseHeaders["Content-Type"] = "application/json"
            return baseHeaders
        case .testNickname:
            return baseHeaders
        }
    }

    var sampleData: Data {
        return Data()
    }
}
