//
//  AuthAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//


import Foundation
import Moya


enum LoginAPI {
    case googleLogin(accessToken: String, deviceId: String)
    case appleLogin(identityToken: String, deviceId: String)
    case reissueToken(refreshToken: String, deviceId: String)
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .googleLogin:
            return "/api/v1/auth/GOOGLE/login"
        case .appleLogin:
            return "/api/v1/auth/APPLE/login"
        case .reissueToken:
            return "/api/v1/auth/reissue"
        }
    }

    var method: Moya.Method {
        switch self {
        case .googleLogin, .appleLogin, .reissueToken:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .googleLogin(let accessToken, let deviceId):
            let params: [String: Any] = ["accessToken": accessToken, "deviceId": deviceId]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .appleLogin(let identityToken, let deviceId):
            return .requestParameters(parameters: ["identityToken": identityToken, "deviceId": deviceId], encoding: JSONEncoding.default)
        case .reissueToken:
            return .requestPlain
            
        }
    }

    var headers: [String : String]? {
        switch self {
            
        case .reissueToken(let refreshToken, let deviceId):
            return [
                "refreshToken": refreshToken,
                "Device-Id": deviceId
            ]
        default :
            return [
                "Content-Type": "application/json",
                "Accept": "*/*",
                "Accept-Language": "ko-KR,ko;q=0.9"
            ]
        }
        
    }

    var sampleData: Data {
        return Data()
    }
}
